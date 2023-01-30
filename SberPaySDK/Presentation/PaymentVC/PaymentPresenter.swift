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

    private var selectedCard: PaymentToolInfo?
    private var user: User?

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         authManager: AuthManager,
         network: NetworkService,
         personalMetricsService: PersonalMetricsService) {
        self.manager = manager
        self.analytics = analytics
        self.router = router
        self.userService = userService
        self.network = network
        self.authManager = authManager
        self.personalMetricsService = personalMetricsService
    }
    
    func viewDidLoad() {
        getUser()
        analytics.sendEvent(.PayViewAppeared)
    }
    
    func payButtonTapped() {
        getMetrics()
        analytics.sendEvent(.PayConfirmedByUser)
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
        view?.configCardView(with: selectedCard.name,
                             cardInfo: selectedCard.cardNumber.card) { [weak self] in
            self?.router.presentCards(cards: user.paymentToolInfo,
                                      selectedId: selectedCard.paymentId,
                                      selectedCard: { [weak self] card in
                self?.selectedCard = card
                self?.configViews()
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
              let request = manager.paymentTokenRequest
        else { return }
        network.request(PaymentTarget.getPaymentToken(sessionId: sessionId,
                                                      deviceInfo: deviceInfo,
                                                      paymentId: String(paymentId),
                                                      apiKey: request.apiKey,
                                                      userName: request.clientName,
                                                      merchantLogin: request.clientId ?? "",
                                                      orderId: request.orderNumber),
                        to: PaymentTokenModel.self) { [weak self] result in
            switch result {
            case .success(let result):
                self?.manager.completionPaymentToken(with: result.paymentToken)
                self?.view?.showAlert(with: .success)
            case .failure(let error):
                self?.manager.completionWithError(error: error)
                self?.view?.showAlert(with: .failure())
            }
        }
    }
}
