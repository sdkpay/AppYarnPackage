//
//  PaymentPresenter.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import Foundation

protocol PaymentPresenting {
    func viewDidLoad()
    func payButtonTapped()
    func cancelTapped()
}

final class PaymentPresenter: PaymentPresenting {
    private let manager: SDKManager
    private let analytics: AnalyticsService
    private let router: PaymentRouting
    private let userService: UserService
    private let network: NetworkService
    private let authManager: AuthManager
    private let personalMetricsService: PersonalMetricsService
    private let locationManager: LocationManager
    private var selectedCard: PaymentToolInfo?
    private var user: User?

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         authManager: AuthManager,
         network: NetworkService,
         personalMetricsService: PersonalMetricsService,
         locationManager: LocationManager) {
        self.manager = manager
        self.analytics = analytics
        self.router = router
        self.userService = userService
        self.network = network
        self.authManager = authManager
        self.locationManager = locationManager
        self.personalMetricsService = personalMetricsService
    }
    
    func viewDidLoad() {
        if let user = userService.user {
            self.user = user
            selectedCard = user.paymentToolInfo.first(where: { $0.priorityCard })
            configViews()
        } else {
            getUser()
        }
        analytics.sendEvent(.PayViewAppeared)
    }
    
    func payButtonTapped() {
        getMetrics()
        analytics.sendEvent(.PayConfirmedByUser)
        let permission = locationManager.locationEnabled ? [AnalyticsValue.Location.rawValue] : []
        analytics.sendEvent(.Permissions, with: permission)
    }
    
    func cancelTapped() {
        view?.dismiss(animated: true)
    }
    
    private func getUser() {
        view?.showLoading(animate: false)
        userService.getUser { [weak self] result in
            self?.view?.hideLoading()
            switch result {
            case .success(let user):
                self?.user = user
                self?.selectedCard = user.paymentToolInfo.first(where: { $0.priorityCard })
                self?.configViews()
            case .failure(let error):
                self?.view?.showAlert(with: .failure())
                self?.manager.completionWithError(error: error)
            }
        }
    }

    private func configViews() {
        guard let user = user,
              let selectedCard = selectedCard
        else { return }
        view?.configShopInfo(with: user.merchantName, cost: user.orderAmount.amount.price)
        view?.configCardView(with: selectedCard.productName,
                             cardInfo: selectedCard.cardNumber.card,
                             needArrow: user.paymentToolInfo.count > 1) { [weak self] in
            self?.router.presentCards(cards: user.paymentToolInfo,
                                      selectedId: selectedCard.paymentId,
                                      selectedCard: { [weak self] card in
                if user.paymentToolInfo.count > 1 {
                    self?.selectedCard = card
                    self?.configViews()
                }
            })
        }
        view?.configProfileView(with: user.userInfo)
    }
    
    private func getMetrics() {
        view?.showLoading(with: .Loading.tryToPayTitle)
        personalMetricsService.getUserData { [weak self] deviceInfo in
            if let deviceInfo = deviceInfo {
                SBLogger.log(.biZone + deviceInfo)
                self?.getPaymentToken(with: deviceInfo)
            } else {
                self?.manager.completionWithError(error: .personalInfo)
            }
        }
    }
    
    private func getPaymentToken(with deviceInfo: String) {
        guard let sessionId = authManager.sessionId,
              let paymentId = selectedCard?.paymentId,
              let authInfo = manager.authInfo
        else { return }
        network.request(PaymentTarget.getPaymentToken(sessionId: sessionId,
                                                      deviceInfo: deviceInfo,
                                                      paymentId: String(paymentId),
                                                      apiKey: authInfo.apiKey,
                                                      userName: authInfo.clientName,
                                                      merchantLogin: authInfo.clientId ?? "",
                                                      orderId: authInfo.orderId),
                        to: PaymentTokenModel.self) { [weak self] result in
            guard let self = self else { return }
            self.userService.clearData()
            switch result {
            case .success(let result):
                switch self.manager.payStrategy {
                case .auto:
                    self.pay(with: result.paymentToken)
                case .manual:
                    self.manager.completionPaymentToken(with: result.paymentToken)
                    self.view?.showAlert(with: .success)
                }
            case .failure(let error):
                self.manager.completionWithError(error: error)
                self.view?.showAlert(with: .failure())
            }
        }
    }
    
    private func pay(with token: String) {
        network.request(PaymentTarget.getPaymentOrder) { [weak self] result in
            switch result {
            case .success:
                self?.manager.completionPay(with: nil)
                self?.view?.showAlert(with: .success)
            case .failure(let error):
                self?.manager.completionPay(with: error)
                self?.view?.showAlert(with: .failure())
            }
        }
    }
}
