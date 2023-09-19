//
//  PaymentPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import Foundation
import UIKit

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
    func openProfile()
    func viewDidAppear()
    func viewDidDisappear()
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
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private var authService: AuthService
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private let timeManager: OptimizationCheсkerManager
    private var partPayService: PartPayService
    private let biometricAuthProvider: BiometricAuthProviderProtocol
    private let otpService: OTPService

    private var cellData: [PaymentCellType] {
        var cellData: [PaymentCellType] = []
        cellData.append(.card)
        if partPayService.bnplplan != nil,
           partPayService.bnplplanEnabled {
            cellData.append(.partPay)
        }
        return cellData
    }
    
    private let screenEvent = "screen: PaymentVC"
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         bankManager: BankAppManager,
         paymentService: PaymentService,
         locationManager: LocationManager,
         alertService: AlertService,
         authService: AuthService,
         partPayService: PartPayService,
         authManager: AuthManager,
         biometricAuthProvider: BiometricAuthProviderProtocol,
         otpService: OTPService,
         timeManager: OptimizationCheсkerManager) {
        self.router = router
        self.userService = userService
        self.sdkManager = manager
        self.analytics = analytics
        self.authService = authService
        self.paymentService = paymentService
        self.locationManager = locationManager
        self.alertService = alertService
        self.partPayService = partPayService
        self.biometricAuthProvider = biometricAuthProvider
        self.bankManager = bankManager
        self.timeManager = timeManager
        self.authManager = authManager
        self.otpService = otpService
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        configViews()
        timeManager.endTraking(PaymentVC.self.description()) {_ in 
//            self.analytics.sendEvent(.PayViewAppeared, with: [$0])
        }
    }
    
    private func updatePayButtonTitle() {
        let buttonTitle = partPayService.bnplplanSelected ? Strings.Part.Active.Button.title : Strings.Pay.title
        view?.setPayButtonTitle(title: buttonTitle)
    }
    
    func payButtonTapped() {
        analytics.sendEvent(.TouchPay, with: screenEvent)
        goToPay()
    }
    
    func viewDidAppear() {
        analytics.sendEvent(.LCPayViewAppeared, with: screenEvent)
    }
    
    func viewDidDisappear() {
        analytics.sendEvent(.LCPayViewDisappeared, with: screenEvent)
    }
    
    func cancelTapped() {
        analytics.sendEvent(.TouchCancel, with: screenEvent)
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
        let cellType = cellData[indexPath.row]
        switch cellType {
        case .card:
            analytics.sendEvent(.TouchCard, with: screenEvent)
            cardTapped()
        case .partPay:
            analytics.sendEvent(.TouchBNPL, with: screenEvent)
            router.presentPartPay { [weak self] in
                self?.configViews()
                self?.updatePayButtonTitle()
            }
        }
    }
    
    func openProfile() {
        guard let user = userService.user else { return }
        router.openProfile(with: user.userInfo)
    }
    
    private func cardTapped() {
        guard let selectedCard = userService.selectedCard,
              let user = userService.user,
              let authMethod = authManager.authMethod else { return }

        switch userService.getListCards {
        case true:
            guard user.paymentToolInfo.count > 1 else { return }
            router.presentCards(cards: user.paymentToolInfo,
                                selectedId: selectedCard.paymentId,
                                selectedCard: { [weak self] card in
                self?.view?.hideLoading(animate: true)
                self?.userService.selectedCard = card
                self?.view?.reloadCollectionView()
            })
        case false:
            guard user.additionalCards == true else { return }
            switch authMethod {
            case .refresh:
                biometricAuthProvider.evaluate { result, _ in
                    self.analytics.sendEvent(.LСBioAuthStart, with: self.screenEvent)
                    switch result {
                    case true:
                        self.analytics.sendEvent(.LСGoodBioAuth, with: self.screenEvent)
                        self.getListCards()
                    case false:
                        self.analytics.sendEvent(.LСFailBioAuth, with: self.screenEvent)
                        self.appAuth()
                    }
                }
            case .bank:
                getListCards()
            }
        }
    }
    
    private func getListCards() {
        view?.showLoading()
        userService.getListCards { [weak self] result in
            switch result {
            case .success:
                self?.cardTapped()
            case .failure(let error):
                self?.view?.hideLoading(animate: true)
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.getListCards() },
                                                              completion: { self?.dismissWithError(error) }))
                } else {
                    self?.alertService.show(on: self?.view,
                                            type: .defaultError(completion: { self?.dismissWithError(error) }))
                }
            }
        }
    }
    
    private func createOTP() {
        view?.showLoading()
        otpService.creteOTP { [weak self] result in
            switch result {
            case .success:
                self?.router.presentOTPScreen(completion: { [weak self] in
                    self?.pay()
                })
            case .failure(let error):
                self?.view?.hideLoading(animate: true)
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.createOTP() },
                                                              completion: { self?.dismissWithError(error) }))
                } else {
                    self?.alertService.show(on: self?.view,
                                            type: .defaultError(completion: { self?.dismissWithError(error) }))
                }
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
                                            type: .full) {
            self.view?.dismiss(animated: true,
                               completion: {
                self.sdkManager.completionWithError(error: .noCards)
            })
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
        guard let paymentId = userService.selectedCard?.paymentId else {
            alertService.show(on: view,
                              type: .defaultError(completion: {
                self.dismissWithError(.badResponseWithStatus(code: .errorSystem)) }))
            return
        }
        paymentService.tryToGetPaymenyToken(paymentId: paymentId,
                                            isBnplEnabled: false) { result in
            switch result {
            case .success:
                self.view?.reloadCollectionView()
                self.alertService.show(on: self.view,
                                       type: .partPayError(fullPay: {
                    self.goToPay()
                }, back: {
                    self.view?.hideLoading(animate: true)
                }))
            case .failure(let failure):
                self.validatePayError(failure)
            }
        }
    }
    
    private func configForWaiting() {
        let okButton = AlertButtonModel(title: Strings.Ok.title,
                                        type: .full) {
            self.view?.dismiss(animated: true,
                               completion: { [weak self] in
                self?.sdkManager.completionPay(with: .waiting)
            })
        }
        alertService.showAlert(on: view,
                               with: ConfigGlobal.localization?.payLoading ?? "",
                               state: .waiting,
                               buttons: [okButton],
                               completion: {
            self.view?.hideLoading(animate: true)
        })
    }
    
    private func dismissWithError(_ error: SDKError) {
        alertService.close(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: error)
        })
    }
    
    private func appAuth() {
        analytics.sendEvent(.LCBankAppAuth, with: screenEvent)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        authService.appAuth { [weak self] result in
            guard let self else { return }
            self.view?.showLoading()
            NotificationCenter.default.removeObserver(self,
                                                      name: UIApplication.didBecomeActiveNotification,
                                                      object: nil)
            switch result {
            case .success:
                self.analytics.sendEvent(.LCBankAppAuthGood, with: self.screenEvent)
                self.authService.refreshAuth { result in
                    switch result {
                    case .success:
                        self.authService.bankCheck = true
                        self.getListCards()
                    case .failure(_):
                        self.analytics.sendEvent(.LCBankAppAuthFail, with: self.screenEvent)
                        self.alertService.show(on: self.view,
                                               type: .defaultError(completion: {
                            self.dismissWithError(.badResponseWithStatus(code: .errorSystem)) }))
                    }
                }
            case .failure(_):
                self.alertService.show(on: self.view,
                                       type: .defaultError(completion: {
                    self.dismissWithError(.badResponseWithStatus(code: .errorSystem)) }))
            }
        }
    }
    
    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        alertService.show(on: view,
                          type: .defaultError(completion: {
            self.dismissWithError(.badResponseWithStatus(code: .errorSystem)) }))
    }
    
    private func goToPay() {
        if sdkManager.authInfo?.orderNumber != nil || authManager.authMethod == .bank || authService.bankCheck {
            pay()
        } else {
            createOTP()
        }
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
//                self.analytics.sendEvent(.PayWithBNPLConfirmedByUser)
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
//                    self.analytics.sendEvent(.PayWithBNPLFailed)
                }
                self.validatePayError(error)
            }
        }
    }
}
