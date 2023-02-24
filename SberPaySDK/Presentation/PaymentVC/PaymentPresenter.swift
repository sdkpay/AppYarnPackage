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
    private let analytics: AnalyticsService
    private let router: PaymentRouting
    private let userService: UserService
    private let paymentService: PaymentService
    private let locationManager: LocationManager
    private let manager: SDKManager
    
    private var selectedCard: PaymentToolInfo?
    private var user: User?

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         paymentService: PaymentService,
         locationManager: LocationManager) {
        self.router = router
        self.userService = userService
        self.manager = manager
        self.analytics = analytics
        self.paymentService = paymentService
        self.locationManager = locationManager
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
        analytics.sendEvent(.PayViewAppeared)
    }
    
    func payButtonTapped() {
        analytics.sendEvent(.PayConfirmedByUser)
        let permission = locationManager.locationEnabled ? [AnalyticsValue.Location.rawValue] : []
        analytics.sendEvent(.Permissions, with: permission)
        pay()
    }
    
    private func pay() {
        view?.showLoading(with: .Loading.tryToPayTitle)
        guard let paymentId = selectedCard?.paymentId else { return }
        paymentService.tryToPay(paymentId: paymentId) { [weak self] error in
            if let error = error {
                self?.view?.showAlert(with: .failure()) {
                    self?.view?.dismiss(animated: true, completion: {
                        self?.manager.completionPay(with: error)
                    })
                }
            } else {
                self?.view?.showAlert(with: .success, completion: {
                    self?.view?.dismiss(animated: true, completion: {
                        self?.manager.completionPay(with: nil)
                    })
                })
            }
        }
    }
    
    func cancelTapped() {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.manager.completionWithError(error: .cancelled)
        })
    }
    
    private func getUser() {
        view?.showLoading(animate: false)
        userService.getUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                self?.selectedCard = user.paymentToolInfo.first(where: { $0.priorityCard })
                self?.configViews()
            case .failure(let error):
                self?.view?.showAlert(with: .failure(),
                                      completion: {
                    self?.view?.dismiss(animated: true, completion: {  self?.manager.completionWithError(error: error)
                    })
                })
            }
        }
    }

    private func configViews() {
        guard let user = user else { return }

        view?.configShopInfo(with: user.merchantName,
                             cost: user.orderAmount.amount.price(with: user.orderAmount.currency))
        view?.configProfileView(with: user.userInfo)

        if let selectedCard = selectedCard {
            view?.hideLoading()
            view?.configCardView(with: selectedCard.productName,
                                 cardInfo: selectedCard.cardNumber.card,
                                 cardIconURL: selectedCard.cardLogoUrl,
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
        } else {
            view?.showAlert(with: .failure(text: .Alert.alertPayNoCardsTitle),
                            animate: false,
                            buttonTitle: .Common.returnTitle,
                            completion: {
                self.view?.dismiss(animated: true, completion: {
                    self.manager.completionWithError(error: .noCards)
                })
            })
        }
    }
}
