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
    var cellDataCount: Int {
        cellData.count
    }

    weak var view: (IPaymentVC & ContentVC)?
    private let router: PaymentRouting
    private let analytics: AnalyticsService
    private var userService: UserService
    private let paymentService: PaymentService
    private let locationManager: LocationManager
    private let completionManager: CompletionManager
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private let timeManager: OptimizationCheсkerManager
    private var partPayService: PartPayService

    private var cellData: [PaymentCellType] {
        var cellData: [PaymentCellType] = []
        cellData.append(.card)
        if partPayService.bnplplanEnabled {
            cellData.append(.partPay)
        }
        return cellData
    }
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         bankManager: BankAppManager,
         paymentService: PaymentService,
         locationManager: LocationManager,
         completionManager: CompletionManager,
         alertService: AlertService,
         partPayService: PartPayService,
         timeManager: OptimizationCheсkerManager) {
        self.router = router
        self.userService = userService
        self.completionManager = completionManager
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
    
    private func updatePayButtonTitle() {
        let buttonTitle = partPayService.bnplplanSelected ? Strings.Part.Active.Button.title : Strings.Pay.title
        view?.setPayButtonTitle(title: buttonTitle)
    }
    
    func payButtonTapped() {
        analytics.sendEvent(.PayConfirmedByUser)
        let permission = locationManager.locationEnabled ? [AnalyticsValue.Location.rawValue] : []
        analytics.sendEvent(.Permissions, with: permission)
        pay()
    }
    
    func cancelTapped() {
        self.completionManager.dismissCloseAction(view)
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
                self?.updatePayButtonTitle()
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
        updatePayButtonTitle()
    }
    
    private func configWithNoCards() {
        let returnButton = AlertButtonModel(title: Strings.Return.title,
                                            type: .full) { [weak self] in
            self?.completionManager.completeWithError(.noCards)
            self?.completionManager.dismissCloseAction(self?.view)
        }
        alertService.showAlert(on: self.view,
                               with: Strings.Alert.Pay.No.Cards.title,
                               state: .failure,
                               buttons: [returnButton],
                               completion: {})
    }

    private func validatePayError(_ error: PayError) {
        switch error {
        case .noInternetConnection:
            self.completionManager.completeWithError(.badResponseWithStatus(code: .errorSystem))
            alertService.show(on: view,
                              type: .noInternet(retry: {
                self.pay()
            },
                                                completion: {
                self.alertService.close()
            }))
        case .timeOut, .unknownStatus:
            configForWaiting()
        case .partPayError:
            getPaymentToken()
        default:
            self.completionManager.completeWithError(.badResponseWithStatus(code: .errorSystem))
            alertService.show(on: view,
                              type: .defaultError(completion: {
                self.alertService.close()
            }))
        }
    }
    
    private func getPaymentToken() {
        partPayService.bnplplanSelected = false
        partPayService.setEnabledBnpl(false, enabledLevel: .paymentToken)
        guard let paymentId = userService.selectedCard?.paymentId else {
            self.completionManager.completeWithError(.badResponseWithStatus(code: .errorSystem))
            alertService.show(on: view,
                              type: .defaultError(completion: {
                self.alertService.close()
            }))
            return
        }
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
        self.completionManager.completePay(with: .waiting)
        let okButton = AlertButtonModel(title: Strings.Ok.title,
                                        type: .full) { [weak self] in
            self?.alertService.close()
        }
        alertService.showAlert(on: view,
                               with: ConfigGlobal.localization?.payLoading ?? "",
                               state: .waiting,
                               buttons: [okButton],
                               completion: {
            self.view?.hideLoading(animate: true)
        })
    }

    private func pay() {
        view?.userInteractionsEnabled = false
        DispatchQueue.main.async {
            self.view?.showLoading(with: Strings.Try.To.Pay.title, animate: false)
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
                self.completionManager.completePay(with: .success)
                self.alertService.show(on: self.view, type: .paySuccess(completion: {
                    self.alertService.close()
                }))
            case .failure(let error):
                if self.partPayService.bnplplanSelected {
                    self.analytics.sendEvent(.PayWithBNPLFailed)
                }
                self.validatePayError(error)
            }
        }
    }
}
