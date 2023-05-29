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

    private var cellData: [PaymentCellType] = []
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
        cellData = configCellData()
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
            self.view?.hideAlert()
            self.view?.showLoading(with: .Loading.tryToPayTitle)
        }
        guard let paymentId = userService.selectedCard?.paymentId else { return }
        paymentService.tryToPay(paymentId: paymentId,
                                isBnplEnabled: partPayService.bnplplanSelected) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.hideLoading()
            }
            self?.view?.userInteractionsEnabled = true
            switch result {
            case .success():
                self?.alertService.show(on: self?.view, type: .paySuccess(completion: {
                    self?.view?.dismiss(animated: true, completion: {
                        self?.sdkManager.completionPay(with: .success)
                    })
                }))
            case .failure(let error):
                self?.validatePayError(error)
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
            return configCardModel()
        case .partPay:
            return configPartModel()
        }
    }
    
    private func configCardModel() -> PaymentCellModel {
        guard let selectedCard = userService.selectedCard,
              let user = userService.user else { return PaymentCellModel() }
        return PaymentCellModel(title: selectedCard.productName ?? "",
                                subtitle: selectedCard.cardNumber.card,
                                iconURL: selectedCard.cardLogoUrl,
                                needArrow: user.paymentToolInfo.count > 1)
    }
    
    private func configPartModel() -> PaymentCellModel {
        guard let bnpl = partPayService.bnplplan,
              let buttonBnpl = bnpl.buttonBnpl
        else { return PaymentCellModel() }
        let icon = partPayService.bnplplanSelected ? buttonBnpl.activeButtonLogo : buttonBnpl.inactiveButtonLogo
        return PaymentCellModel(title: buttonBnpl.header,
                                subtitle: buttonBnpl.content,
                                iconURL: icon,
                                needArrow: true)
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
        var buttons: [(title: String,
                       type: DefaultButtonAppearance,
                       action: Action)] = []
        buttons.append((title: .Common.returnTitle,
                        type: .full,
                        action: {
            self.view?.dismiss(animated: true,
                               completion: {
                self.sdkManager.completionWithError(error: .noCards)
            })
        }))
        alertService.showAlert(on: self.view,
                               with: .Alert.alertPayNoCardsTitle,
                               state: .failure,
                               buttons: buttons,
                               completion: {})
    }
    
    private func configCellData() -> [PaymentCellType] {
        var cellData: [PaymentCellType] = []
        cellData.append(.card)
        if partPayService.bnplplan != nil,
           partPayService.bnplplanEnabled {
            cellData.append(.partPay)
        }
        return cellData
    }
    
    private func validatePayError(_ error: PayError) {
        switch error {
        case .noInternetConnection:
            alertService.show(on: view,
                              type: .noInternet(retry: { self.pay() },
                                                completion: { self.dismissWithError(.badResponseWithStatus(code: .errorSystem)) }))
        case .timeOut:
            configForWaiting()
        case .personalInfo:
            <#code#>
        case .partPayError:
            <#code#>
        case .unknownStatus:
            <#code#>
        case .defaultError, .personalInfo:
            alertService.show(on: view,
                              type: .defaultError(completion: { self.dismissWithError(.badResponseWithStatus(code: .errorSystem) }))
        }
        switch error {
        case .noInternetConnection:
            alertService.show(on: view,
                              type: .noInternet(retry: { self.pay() },
                                                completion: { self.dismissWithError(error) }))
        case .timeOut:
            configForWaiting()
        case .partPayError:
            alertService.show(on: self.view,
                              type: .partPayError(fullPay: { [weak self] in
                self?.partPayService.bnplplanSelected = false
                self?.pay()
            }, back: {
                // TODO - показываем экран без бнпл
            }))
        default:
            alertService.show(on: view,
                              type: .defaultError(completion: { self.dismissWithError(error) }))
        }
    }

    private func configForWaiting() {
        var buttons: [(title: String,
                       type: DefaultButtonAppearance,
                       action: Action)] = []
        buttons.append((title: .Common.okTitle,
                        type: .full,
                        action: {
            self.view?.dismiss(animated: true, completion: { [weak self] in
                self?.sdkManager.completionPay(with: .waiting)
            })
        }))
        alertService.showAlert(on: view,
                               with: .Alert.waiting(args: bankManager.selectedBank?.name ?? ""),
                               state: .waiting,
                               buttons: buttons,
                               completion: {})
    }
    
    private func dismissWithError(_ error: SDKError) {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: error)
        })
    }
}
