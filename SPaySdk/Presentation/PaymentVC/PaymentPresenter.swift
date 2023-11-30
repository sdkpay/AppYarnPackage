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

enum PaymentFeature: Int, CaseIterable {
    case bnpl
}

protocol PaymentPresenting {
    var featureCount: Int { get }
    func identifiresForSection(_ section: PaymentSection) -> [Int]
    func model(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectItem(at indexPath: IndexPath)
    func viewDidLoad()
    func payButtonTapped()
    func cancelTapped()
    func profileTapped()
    func viewDidAppear()
    func viewDidDisappear()
}

final class PaymentPresenter: PaymentPresenting {
    
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
    private var secureChallengeService: SecureChallengeService
    private var finalCost: String = ""
    
    private var activeFeatures: [PaymentFeature] {
        
        var features = [PaymentFeature]()
        
        if partPayService.bnplplanEnabled {
            features.append(.bnpl)
        }
        return features
    }
    
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
         secureChallengeService: SecureChallengeService,
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
        self.secureChallengeService = secureChallengeService
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
    }
    
    func payButtonTapped() {
        analytics.sendEvent(.TouchPay, with: screenEvent)
        
        Task {
           await goToPay()
        }
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
            return activeFeatures.map { $0.rawValue }
        case .card:
            if let paymentId = userService.selectedCard?.paymentId {
                return [paymentId]
            } else {
                return []
            }
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
                                          cardBalanceNeed: featureToggle.isEnabled(.cardBalance),
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
                self?.view?.reloadData()
            }
        }
    }
    
    func profileTapped() {
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
            case .sid:
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
    
    private func createOTP() async {
        do {
            await view?.showLoading()
            try await otpService.creteOTP()
            
            try await withCheckedThrowingContinuation({( inCont: CheckedContinuation<Void, Error>) -> Void in
                
                self.router.presentOTPScreen(completion: {
                    inCont.resume()
                })
            })
        } catch {
            
            await view?.hideLoading(animate: true)
            
            if let error = error as? SDKError {
                self.alertService.show(on: self.view,
                                       type: .defaultError(completion: { self.dismissWithError(error) }))
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
                self.pay(resolution: nil)
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
        
        Task { @MainActor [alertService] in
            do {
                try await paymentService.getPaymentToken(paymentId: paymentId,
                                                         isBnplEnabled: false, 
                                                         resolution: nil)
                
                self.view?.reloadData()
                alertService.show(on: self.view, type: .partPayError(fullPay: {
                    Task {
                        await self.goToPay()
                    }
                }, back: {
                    Task {
                        self.view?.hideLoading(animate: true)
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
        let okButton = AlertButtonModel(title: Strings.Cancel.title,
                                        type: .full) { [weak self] in
            self?.alertService.close()
        }
        alertService.showAlert(on: view,
                               with: Strings.Alert.Pay.No.Waiting.title,
                               with: ConfigGlobal.localization?.payLoading ?? "",
                               with: nil,
                               state: .success,
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
        
        if otpService.otpRequired {
            await createOTP()
        }

        do {
            await self.view?.showLoading(with: Strings.Try.To.Pay.title, animate: false)

            let challengeState = try await secureChallengeService.challenge(paymentId: paymentId, 
                                                                            isBnplEnabled: partPayService.bnplplanSelected)
            
            switch challengeState {
            case .review:
               let resolution = await getChallengeResolution()
                
                switch secureChallengeService.fraudMonСheckResult?.secureChallengeFactor {
                case .hint:
                    self.pay(resolution: resolution)
                case .sms:
                    await self.createOTP()
                    self.pay(resolution: resolution)
                case .none:
                    showSecureError()
                }
            case .deny:
                showSecureError()
            case nil:
                pay(resolution: nil)
            }
        } catch {
            if let error = error as? PayError {
                self.validatePayError(error)
            } else if let error = error as? SDKError {
                self.dismissWithError(error)
            }
        }
    }
    
    @MainActor
    private func getChallengeResolution() async -> SecureChallengeResolution? {
        
        do {
            let result = try await withCheckedThrowingContinuation({( inCont: CheckedContinuation<SecureChallengeResolution?, Error>) -> Void in
                
                router.presentChallenge(completion: { resolution in
                    inCont.resume(with: .success(resolution))
                })
            })
            
            return result
        } catch {
            return nil
        }
    }
    
    private func dismissWithError(_ error: SDKError) {
        self.completionManager.completeWithError(error)
        alertService.close()
    }
    
    private func showSecureError() {
        
        let formParameters = secureChallengeService.fraudMonСheckResult?.formParameters
        
        let returnButton = AlertButtonModel(title: formParameters?.buttonDeclineText ?? "",
                                            type: .full) { [weak self] in
            self?.completionManager.completeWithError(SDKError(.errorSystem))
            self?.alertService.close()
        }

        alertService.showAlert(on: self.view,
                               with: formParameters?.header ?? "",
                               with: formParameters?.textDecline ?? "",
                               with: nil,
                               state: .failure,
                               buttons: [returnButton],
                               completion: {})
    }
    
    private func pay(resolution: SecureChallengeResolution?) {
        
        guard let paymentId = userService.selectedCard?.paymentId else { return }
        
        Task {
            await self.view?.showLoading()
            await view?.setUserInteractionsEnabled(false)
            do {
                try await paymentService.tryToPay(paymentId: paymentId,
                                                  isBnplEnabled: partPayService.bnplplanSelected,
                                                  resolution: resolution)
                self.userService.clearData()
                self.partPayService.bnplplanSelected = false
                self.completionManager.completePay(with: .success)
                await view?.setUserInteractionsEnabled()
                self.alertService.show(on: self.view, type: .paySuccess(completion: {
                    self.alertService.close()
                }))
            } catch {
                self.userService.clearData()
                self.partPayService.bnplplanSelected = false
                await view?.setUserInteractionsEnabled()
                
                if let error = error as? PayError {
                    self.validatePayError(error)
                } else if let error = error as? SDKError {
                    self.dismissWithError(error)
                }
            }
        }
    }
}
