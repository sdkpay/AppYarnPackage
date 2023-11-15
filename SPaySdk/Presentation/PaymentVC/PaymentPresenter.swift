//
//  PaymentPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import Foundation
import UIKit

enum PaymentSection: Int, CaseIterable {
    case features
    case card
}

protocol PaymentPresenting {
    var featureCount: Int { get }
    var activeMainSections: [PaymentSection] { get }
    func identifiresForSection(_ section: PaymentSection) -> [Int]
    func model(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectItem(at indexPath: IndexPath)
    func viewDidLoad()
    func payButtonTapped()
    func cancelTapped()
    func openProfile()
    func viewDidAppear()
    func viewDidDisappear()
}

final class PaymentPresenter: PaymentPresenting {
    
    var activeMainSections: [PaymentSection] {
        var activeSections: [PaymentSection] = [.card]
        if partPayService.bnplplanEnabled {
            activeSections.append(.features)
        }
        return activeSections
    }
    
    var featureCount: Int {
        partPayService.bnplplanEnabled ? 1 : 0
    }

    weak var view: (IPaymentVC & ContentVC)?
    private let router: PaymentRouting
    private let analytics: AnalyticsService
    private var userService: UserService
    private let paymentService: PaymentService
    private let locationManager: LocationManager
    private let completionManager: CompletionManager
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private var authService: AuthService
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private let timeManager: OptimizationCheсkerManager
    private var partPayService: PartPayService
    private let biometricAuthProvider: BiometricAuthProviderProtocol
    private let otpService: OTPService
    private let featureToggle: FeatureToggleService
    private var finalCost: String = ""
    
    private let screenEvent = [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue]
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         bankManager: BankAppManager,
         paymentService: PaymentService,
         locationManager: LocationManager,
         completionManager: CompletionManager,
         alertService: AlertService,
         authService: AuthService,
         partPayService: PartPayService,
         authManager: AuthManager,
         biometricAuthProvider: BiometricAuthProviderProtocol,
         featureToggle: FeatureToggleService,
         otpService: OTPService,
         timeManager: OptimizationCheсkerManager) {
        self.router = router
        self.sdkManager = manager
        self.userService = userService
        self.completionManager = completionManager
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
        self.featureToggle = featureToggle
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        configViews()
        view?.addSnapShot()
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
        self.completionManager.dismissCloseAction(view)
    }
    
    func identifiresForSection(_ section: PaymentSection) -> [Int] {
        
        switch section {
        case .features:
            // DEBUG
            return [899879798797789]
        case .card:
            return userService.user?.paymentToolInfo.map({ $0.paymentId }) ?? []
        }
    }
    
    func model(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return nil }
        
        switch section {
        case .features:
            
            guard let buttonBnpl = partPayService.bnplplan?.buttonBnpl else { return nil }
            
            return PartPayModelFactory.build(indexPath,
                                             buttonBnpl: buttonBnpl,
                                             bnplplanSelected: partPayService.bnplplanSelected)
            
        case .card:
            
            guard let selectedCard = userService.selectedCard else { return nil }
            return CardModelFactory.build(indexPath,
                                          selectedCard: selectedCard,
                                          additionalCards: userService.additionalCards,
                                          compoundWalletNeed: featureToggle.isEnabled(.compoundWallet))
        }
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .card:
            analytics.sendEvent(.TouchCard, with: screenEvent)
            cardTapped()
        case .features:
            analytics.sendEvent(.TouchBNPL, with: screenEvent)
            router.presentPartPay { [weak self] in
                self?.configViews()
                self?.updatePayButtonTitle()
                self?.view?.reloadData()
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
            guard userService.additionalCards else { return }
            Task { @MainActor in
                self.router.presentCards(cards: user.paymentToolInfo,
                                         cost: finalCost,
                                         selectedId: selectedCard.paymentId,
                                         selectedCard: { [weak self] card in
                    self?.view?.hideLoading(animate: true)
                    self?.userService.selectedCard = card
                    self?.view?.reloadData()
                })
            }
        case false:
            guard userService.additionalCards else { return }
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
        
        Task {
            do {
                await view?.showLoading()
                try await userService.getListCards()
                self.cardTapped()
            } catch {
                await self.view?.hideLoading(animate: true)
                if let error = error as? SDKError {
                    if error.represents(.noInternetConnection) {
                        self.alertService.show(on: self.view,
                                               type: .noInternet(retry: { self.getListCards() },
                                                                 completion: { self.dismissWithError(error) }))
                    } else {
                        self.alertService.show(on: self.view,
                                               type: .defaultError(completion: { self.dismissWithError(error) }))
                    }
                }
            }
        }
    }
    
    private func createOTP() {
        
        Task {
            do {
                await view?.showLoading()
                try await otpService.creteOTP()
                self.router.presentOTPScreen(completion: { [weak self] in
                    self?.pay()
                })
            } catch {
                await view?.hideLoading(animate: true)
                
                if let error = error as? SDKError {
                    if error.represents(.noInternetConnection) {
                        self.alertService.show(on: self.view,
                                               type: .noInternet(retry: { self.createOTP() },
                                                                 completion: { self.dismissWithError(error) }))
                    } else {
                        self.alertService.show(on: self.view,
                                               type: .defaultError(completion: { self.dismissWithError(error) }))
                    }
                }
            }
        }
    }
    
    private func configViews() {
        guard let user = userService.user else { return }
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
        
        if userService.selectedCard != nil {
        view?.addSnapShot()
        } else {
            configWithNoCards()
        }
        updatePayButtonTitle()
    }
    
    private func configWithNoCards() {
        let returnButton = AlertButtonModel(title: Strings.Return.title,
                                            type: .full) { [weak self] in
            self?.completionManager.completeWithError(SDKError(.noCards))
            self?.completionManager.dismissCloseAction(self?.view)
        }
        alertService.showAlert(on: self.view,
                               with: Strings.Alert.Pay.No.Cards.title,
                               with: Strings.Alert.Pay.No.Cards.subtitle,
                               with: nil,
                               state: .failure,
                               buttons: [returnButton],
                               completion: {})
    }

    private func validatePayError(_ error: PayError) {
        switch error {
        case .noInternetConnection:
            self.completionManager.completeWithError(SDKError(.errorSystem))
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
            self.completionManager.completeWithError(SDKError(.errorSystem))
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
            self.completionManager.completeWithError(SDKError(.errorSystem))
            alertService.show(on: view,
                              type: .defaultError(completion: {
                self.alertService.close()
            }))
            return
        }
        
        Task {
            do {
                try await paymentService.getPaymentToken(paymentId: paymentId,
                                                         isBnplEnabled: false)
                
                self.view?.reloadData()
                self.alertService.show(on: self.view,
                                       type: .partPayError(fullPay: {
                    self.goToPay()
                }, back: {
                    Task {
                        await self.view?.hideLoading(animate: true)
                    }
                }))
            } catch {
                if let error = error as? PayError {
                    self.validatePayError(error)
                } else if let error = error as? SDKError {
                    self.dismissWithError(error)
                }
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
                               with: ConfigGlobal.localization?.payLoading ?? "",
                               with: nil,
                               state: .waiting,
                               buttons: [okButton],
                               completion: {
            Task {
                await self.view?.hideLoading(animate: true)
            }
        })
    }
    
    private func appAuth() {
        analytics.sendEvent(.LCBankAppAuth, with: screenEvent)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        Task {
            do {
                try await authService.appAuth()
                
                await self.view?.showLoading()
                await NotificationCenter.default.removeObserver(self,
                                                                name: UIApplication.didBecomeActiveNotification,
                                                                object: nil)
                
                self.analytics.sendEvent(.LCBankAppAuthGood, with: self.screenEvent)
                
                try await self.authService.auth()
                
                self.authService.bankCheck = true
                self.getListCards()
            } catch {
                if let error = error as? SDKError {
                    self.analytics.sendEvent(.LCBankAppAuthFail, with: self.screenEvent)
                    self.alertService.show(on: self.view,
                                           type: .defaultError(completion: {
                        self.dismissWithError(error)
                    }))
               }
            }
        }
    }
    
    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        alertService.show(on: view,
                          type: .defaultError(completion: {
            self.dismissWithError(SDKError(.errorSystem)) }))
    }
    
    private func goToPay() async {
        guard let paymentId = userService.selectedCard?.paymentId else { return }
        
        if let challangeMethod = try? await paymentService.getChallangeMethod(paymentId: paymentId,
                                                                              isBnplEnabled: partPayService.bnplplanSelected) {
            
            switch challangeMethod.secureChallengeFactor {
            case .sms:
                print("challangeMethod")
            case .hint:
                print("challangeMethod")
            case .none:
                print("challangeMethod")
            }
            
        } else {
            if sdkManager.authInfo?.orderNumber != nil || authManager.authMethod == .bank || authService.bankCheck {
                pay()
            } else {
                if otpService.otpRequired {
                    createOTP()
                } else {
                    pay()
                }
            }
        }
    }
    
    private func dismissWithError(_ error: SDKError) {
        self.completionManager.completeWithError(error)
        alertService.close()
    }
    
    private func pay() {
        view?.userInteractionsEnabled = false
        DispatchQueue.main.async {
            self.view?.showLoading(with: Strings.Try.To.Pay.title, animate: false)
        }
        
        guard let paymentId = userService.selectedCard?.paymentId else { return }
        self.view?.userInteractionsEnabled = true
        Task {
            
            do {
                try await paymentService.tryToPay(paymentId: paymentId,
                                                  isBnplEnabled: partPayService.bnplplanSelected)
                self.userService.clearData()
                self.partPayService.bnplplanSelected = false
                self.completionManager.completePay(with: .success)
                self.alertService.show(on: self.view, type: .paySuccess(completion: {
                    self.alertService.close()
                }))
            } catch {
                self.userService.clearData()
                self.partPayService.bnplplanSelected = false
                
                if let error = error as? PayError {
                    self.validatePayError(error)
                } else if let error = error as? SDKError {
                    self.dismissWithError(error)
                }
            }
        }
    }
}
