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
    private var selectedCard: PaymentToolInfo?
    private var user: User?

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService) {
        self.manager = manager
        self.analytics = analytics
        self.router = router
        self.userService = userService
    }
    
    func viewDidLoad() {
        getUser()
        analytics.sendEvent(.PayViewAppeared)
    }
    
    func payButtonTapped() {
        // DEBUG
        analytics.sendEvent(.PayConfirmedByUser)
        view?.showAlert(with: .failure())
    }
    
    func cancelTapped() {
        view?.dismiss(animated: true)
    }
    
    private func getUser() {
        view?.view.subviews.forEach({ $0.isHidden = true })
        view?.showLoading(animate: false)
        userService.getUser { [weak self] result in
            self?.view?.hideLoading()
            // TODO - епределать
            self?.view?.view.subviews.forEach({ $0.isHidden = false })
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
}
