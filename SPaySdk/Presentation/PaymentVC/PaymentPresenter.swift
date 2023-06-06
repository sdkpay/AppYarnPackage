//
//  PaymentPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import Foundation

private enum PaymentCellType {
    case card
    case partPay
}

struct PaymentCellModel {
    var title: String
    var subtitle: String
    var iconURL: String?
    var needArrow: Bool
    
    init(title: String, subtitle: String, iconURL: String? = nil, needArrow: Bool) {
        self.title = title
        self.subtitle = subtitle
        self.iconURL = iconURL
        self.needArrow = needArrow
    }
    
    init() {
        self.title = ""
        self.subtitle = ""
        self.iconURL = ""
        self.needArrow = true
    }
}

protocol PaymentPresenting {
    var cellDataCount: Int { get }
    func model(for indexPath: IndexPath) -> PaymentCellModel
    func didSelectItem(at indexPath: IndexPath)
    func viewDidLoad()
    func payButtonTapped()
    func cancelTapped()
}

final class PaymentPresenter: PaymentPresenting {
    private let router: PaymentRouting
    private let analytics: AnalyticsService
    private var userService: UserService
    private let paymentService: PaymentService
    private let locationManager: LocationManager
    private let sdkManager: SDKManager
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private let timeManager: OptimizationCheсkerManager
    
    private var partPayService: PartPayService

    private var cellData: [PaymentCellType] {
        var cellData: [PaymentCellType] = []
        cellData.append(.card)
        if partPayService.bnplplan != nil,
           partPayService.bnplplanEnabled {
            cellData.append(.partPay)
        }
        return cellData
    }

    var cellDataCount: Int {
        cellData.count
    }

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         bankManager: BankAppManager,
         paymentService: PaymentService,
         locationManager: LocationManager,
         alertService: AlertService,
         partPayService: PartPayService,
         timeManager: OptimizationCheсkerManager) {
        self.router = router
        self.userService = userService
        self.sdkManager = manager
        self.analytics = analytics
        self.paymentService = paymentService
        self.locationManager = locationManager
        self.alertService = alertService
        self.partPayService = partPayService
        self.bankManager = bankManager
        self.timeManager = timeManager
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        configViews()
        timeManager.endTraking(PaymentVC.self.description()) {
            self.analytics.sendEvent(.PayViewAppeared, with: [$0])
        }
    }
    
    func payButtonTapped() {
        analytics.sendEvent(.PayConfirmedByUser)
        let permission = locationManager.locationEnabled ? [AnalyticsValue.Location.rawValue] : []
        analytics.sendEvent(.Permissions, with: permission)
        pay()
    }
    
    private func pay() {
        view?.userInteractionsEnabled = false
        DispatchQueue.main.async {
            self.view?.showLoading(with: .Loading.tryToPayTitle, animate: false)
        }
        guard let paymentId = userService.selectedCard?.paymentId else { return }
        paymentService.tryToPay(paymentId: paymentId,
                                isBnplEnabled: partPayService.bnplplanSelected) { [weak self] result in
            guard let self = self else { return }
            self.view?.userInteractionsEnabled = true
            if self.partPayService.bnplplanSelected {
                self.analytics.sendEvent(.PayWithBNPLConfirmedByUser)
            }
            switch result {
            case .success:
                self.alertService.show(on: self.view, type: .paySuccess(completion: {
                    self.alertService.close(animated: true, completion: {
                        self.sdkManager.completionPay(with: .success)
                    })
                }))
            case .failure(let error):
                if self.partPayService.bnplplanSelected {
                    self.analytics.sendEvent(.PayWithBNPLFailed)
                }
                self.validatePayError(error)
            }
        }
    }
    
    func cancelTapped() {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: .cancelled)
        })
    }
    
    func model(for indexPath: IndexPath) -> PaymentCellModel {
        let cellType = cellData[indexPath.row]
        switch cellType {
        case .card:
            return PaymentFeaturesConfig.configCardModel(userService: userService)
        case .partPay:
            return PaymentFeaturesConfig.configPartModel(partPayService: partPayService)
        }
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        guard let selectedCard = userService.selectedCard,
              let user = userService.user else { return }
        let cellType = cellData[indexPath.row]
        switch cellType {
        case .card:
            guard user.paymentToolInfo.count > 1 else { return }
            router.presentCards(cards: user.paymentToolInfo,
                                selectedId: selectedCard.paymentId,
                                selectedCard: { [weak self] card in
                self?.userService.selectedCard = card
                self?.view?.reloadCollectionView()
            })
        case .partPay:
            router.presentPartPay { [weak self] in
                self?.configViews()
            }
        }
    }
    
    private func configViews() {
        guard let user = userService.user else { return }
        var finalCost: String
        var fullPrice: String?
        if partPayService.bnplplanSelected {
            guard let firstPay = partPayService.bnplplan?.graphBnpl?.payments.first else { return }
            finalCost = firstPay.amount.price(firstPay.currencyCode)
            fullPrice = user.orderAmount.amount.price(user.orderAmount.currency)
        } else {
            finalCost = user.orderAmount.amount.price(user.orderAmount.currency)
        }
        view?.configShopInfo(with: user.merchantName ?? "",
                             cost: finalCost,
                             fullPrice: fullPrice,
                             iconURL: user.logoUrl)
        view?.configProfileView(with: user.userInfo)
        
        if userService.selectedCard != nil {
            view?.reloadCollectionView()
        } else {
            configWithNoCards()
        }
    }
    
    private func configWithNoCards() {
        let returnButton = AlertButtonModel(title: .Common.returnTitle,
                                            type: .full) {
            self.view?.dismiss(animated: true,
                               completion: {
                self.sdkManager.completionWithError(error: .noCards)
            })
        }
        alertService.showAlert(on: self.view,
                               with: .Alert.alertPayNoCardsTitle,
                               state: .failure,
                               buttons: [returnButton],
                               completion: {})
    }

    private func validatePayError(_ error: PayError) {
        switch error {
        case .noInternetConnection:
            alertService.show(on: view,
                              type: .noInternet(retry: {
                self.pay()
            },
                                                completion: {
                self.dismissWithError(.badResponseWithStatus(code: .errorSystem)) }))
        case .timeOut, .unknownStatus:
            configForWaiting()
        case .partPayError:
            getPaymentToken()
        default:
            alertService.show(on: view,
                              type: .defaultError(completion: {
                self.dismissWithError(.badResponseWithStatus(code: .errorSystem)) }))
        }
    }
    
    private func getPaymentToken() {
        partPayService.bnplplanSelected = false
        partPayService.setUserEnableBnpl(false, enabledLevel: .server)
        
        guard let paymentId = userService.selectedCard?.paymentId else { return }
        paymentService.tryToGetPaymenyToken(paymentId: paymentId,
                                            isBnplEnabled: false) { result in
            switch result {
            case .success:
                self.view?.reloadCollectionView()
                self.alertService.show(on: self.view,
                                       type: .partPayError(fullPay: {
                    self.pay()
                }, back: {
                    self.view?.hideLoading(animate: true)
                }))
            case .failure(let failure):
                self.validatePayError(failure)
            }
        }
    }
    
    private func configForWaiting() {
        let okButton = AlertButtonModel(title: .Common.okTitle,
                                        type: .full) {
            self.view?.dismiss(animated: true,
                               completion: { [weak self] in
                self?.sdkManager.completionPay(with: .waiting)
            })
        }
        alertService.showAlert(on: view,
                               with: .Alert.waiting(args: bankManager.selectedBank?.name ?? ""),
                               state: .waiting,
                               buttons: [okButton],
                               completion: {})
    }
    
    private func dismissWithError(_ error: SDKError) {
        alertService.close(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: error)
        })
    }
}
