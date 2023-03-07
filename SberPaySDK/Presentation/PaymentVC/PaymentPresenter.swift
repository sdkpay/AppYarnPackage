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
    private let router: PaymentRouting
    private let analytics: AnalyticsService
    private let userService: UserService
    private let paymentService: PaymentService
    private let locationManager: LocationManager
    private let sdkManager: SDKManager
    private let alertService: AlertService
    
    private var selectedCard: PaymentToolInfo?
    private var user: User?

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         paymentService: PaymentService,
         locationManager: LocationManager,
         alertService: AlertService) {
        self.router = router
        self.userService = userService
        self.sdkManager = manager
        self.analytics = analytics
        self.paymentService = paymentService
        self.locationManager = locationManager
        self.alertService = alertService
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
        view?.userInteractionsEnabled = false
        view?.hideAlert()
        view?.showLoading(with: .Loading.tryToPayTitle)
        guard let paymentId = selectedCard?.paymentId else { return }
        paymentService.tryToPay(paymentId: paymentId) { [weak self] error in
            self?.view?.userInteractionsEnabled = true
            if let error = error {
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.pay() },
                                                              completion: { self?.dismissWithError(error) }))
                } else if error.represents(.timeOut) {
                    self?.configForWaiting()
                } else {
                    self?.dismissWithError(error)
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
        view?.hideAlert()
        view?.showLoading(animate: false)
        userService.getUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                self?.selectedCard = user.paymentToolInfo.first(where: { $0.priorityCard }) ?? user.paymentToolInfo.first
                self?.configViews()
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

    private func configViews() {
        guard let user = user else { return }
        
        view?.configShopInfo(with: user.merchantName,
                             cost: user.orderAmount.amount.price(with: Int(user.orderAmount.currency)))
        view?.configProfileView(with: user.userInfo)
        ImageDownloader.shared.downloadImage(with: "https://cms-res.online.sberbank.ru/sberpay/icons/980000084093.png",
                                             completionHandler: { image, _ in
            self.view?.configureLogoImage(image: image)
        },
                                             placeholderImage: .Payment.cart)
        
        if let selectedCard = selectedCard {
            configWithCard(user: user, selectedCard: selectedCard)
        } else {
            configWithNoCards()
        }
    }
    
    private func configWithCard(user: User, selectedCard: PaymentToolInfo) {
        view?.hideLoading()
        view?.configCardView(with: selectedCard.productName ?? "",
                             cardInfo: selectedCard.cardNumber.card,
                             cardIconURL: selectedCard.cardLogoUrl,
                             needArrow: user.paymentToolInfo.count > 1) { [weak self] in
            guard user.paymentToolInfo.count > 1 else { return }
            self?.router.presentCards(cards: user.paymentToolInfo,
                                      selectedId: selectedCard.paymentId,
                                      selectedCard: { [weak self] card in
                self?.selectedCard = card
                self?.configViews()
            })
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
                               with: .Alert.alertPayWaitingTitle,
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
