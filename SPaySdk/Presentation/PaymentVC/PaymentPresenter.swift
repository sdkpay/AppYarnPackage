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
    private let userService: UserService
    private let paymentService: PaymentService
    private let locationManager: LocationManager
    private let sdkManager: SDKManager
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private let timeManager: OptimizationCheсkerManager

    private var cellData: [PaymentCellType] {
        return [
            .card,
            .partPay
        ]
    }
    
    var cellDataCount: Int {
        cellData.count
    }
    
    private var selectedCard: PaymentToolInfo?
    private var user: User?

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         bankManager: BankAppManager,
         paymentService: PaymentService,
         locationManager: LocationManager,
         alertService: AlertService,
         timeManager: OptimizationCheсkerManager) {
        self.router = router
        self.userService = userService
        self.sdkManager = manager
        self.analytics = analytics
        self.paymentService = paymentService
        self.locationManager = locationManager
        self.alertService = alertService
        self.bankManager = bankManager
        self.timeManager = timeManager
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        if let user = userService.user {
            self.user = user
            selectedCard = user.paymentToolInfo
                .first(where: { $0.priorityCard })
            ?? user.paymentToolInfo.first
            configViews()
        } else {
            getUser()
        }
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
            self.view?.hideAlert()
            self.view?.showLoading(with: .Loading.tryToPayTitle)
        }
        guard let paymentId = selectedCard?.paymentId else { return }
        paymentService.tryToPay(paymentId: paymentId) { [weak self] error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.hideLoading()
            }
            self?.view?.userInteractionsEnabled = true
            if let error = error {
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.pay() },
                                                              completion: { self?.dismissWithError(error) }))
                } else if error.represents(.timeOut) || error.represents(.badResponseWithStatus(code: .unowned)) {
                    self?.configForWaiting()
                } else {
                    self?.alertService.show(on: self?.view,
                                            type: .defaultError(completion: { self?.dismissWithError(error) }))
                }
            } else {
                self?.alertService.show(on: self?.view, type: .paySuccess(completion: {
                    self?.view?.dismiss(animated: true, completion: {
                        self?.sdkManager.completionPay(with: .success)
                    })
                }))
            }
        }
    }
    
    func cancelTapped() {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: .cancelled)
        })
    }
    
    private func getUser() {
        DispatchQueue.main.async {
            self.view?.hideAlert()
            self.view?.showLoading(animate: false)
        }
        userService.getUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                self?.selectedCard = user.paymentToolInfo.first(where: { $0.priorityCard }) ?? user.paymentToolInfo.first
                DispatchQueue.main.async { [weak self] in
                    self?.configViews()
                }
            case .failure(let error):
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.getUser() },
                                                              completion: { self?.dismissWithError(error) }))
                } else {
                    self?.alertService.show(on: self?.view,
                                            type: .defaultError(completion: { self?.dismissWithError(error) }))
                }
            }
        }
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
        guard let selectedCard = selectedCard,
                let user = user else { return PaymentCellModel() }
        return PaymentCellModel(title: selectedCard.productName ?? "",
                                subtitle: selectedCard.cardNumber.card,
                                iconURL: selectedCard.cardLogoUrl,
                                needArrow: user.paymentToolInfo.count > 1)
    }
    
    private func configPartModel() -> PaymentCellModel {
        // DEBUG: - Ждем данных с конфига
        return PaymentCellModel(title: "Плати частями",
                                subtitle: "Оформлять",
                                needArrow: true)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        guard let selectedCard = selectedCard,
              let user = user else { return }
        let cellType = cellData[indexPath.row]
        switch cellType {
        case .card:
            guard user.paymentToolInfo.count > 1 else { return }
            router.presentCards(cards: user.paymentToolInfo,
                                selectedId: selectedCard.paymentId,
                                selectedCard: { [weak self] card in
                self?.selectedCard = card
                self?.view?.reloadCollectionView()
            })
        case .partPay:
            // DEBUG - Допилю возврат оплаты частями
            router.presentPartPay { _ in
            }
        }
    }

    private func configViews() {
        guard let user = user else { return }
        
        view?.configShopInfo(with: user.merchantName,
                             cost: user.orderAmount.amount.price(with: Int(user.orderAmount.currency)),
                             iconURL: user.logoUrl)
        view?.configProfileView(with: user.userInfo)

        if selectedCard != nil {
            view?.hideLoading()
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
