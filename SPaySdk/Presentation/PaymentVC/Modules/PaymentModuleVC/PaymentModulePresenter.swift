//
//  PaymentModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.03.2024.
//

import UIKit
import Combine

protocol PaymentModulePresenting: NSObject {

    func payButtonTapped()
    func viewDidLoad()
    
    var view: (IPaymentModuleVC & ModuleVC)? { get set }
}

final class PaymentModulePresenter: NSObject, PaymentModulePresenting {
    
    weak var view: (IPaymentModuleVC & ModuleVC)?
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
    private var partPayService: PartPayService
    private let biometricAuthProvider: BiometricAuthProviderProtocol
    private let otpService: OTPService
    private let featureToggle: FeatureToggleService
    private var secureChallengeService: SecureChallengeService
    private let vcMode: PaymentVCMode
    private var cancellable = Set<AnyCancellable>()
    
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
         vcMode: PaymentVCMode,
         otpService: OTPService) {
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
        self.authManager = authManager
        self.otpService = otpService
        self.vcMode = vcMode
        self.featureToggle = featureToggle
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
        setupPublishers()
    }
    
    func payButtonTapped() {
        
        analytics.sendEvent(.TouchPay, with: screenEvent)
        
        Task {
            await goToPay()
        }
    }

    @MainActor
    private func createOTP() async throws {
        
        view?.contentParrent?.showLoading()
        try await otpService.creteOTP()
        
        try await withCheckedThrowingContinuation({( inCont: CheckedContinuation<Void, Error>) -> Void in
            
            DispatchQueue.main.async {
                self.router.presentOTPScreen(completion: {
                    inCont.resume()
                })
            }
        })
    }
    
    private func setupPublishers() {
        
        partPayService.bnplplanSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bnplplanSelected in
                if bnplplanSelected {
                    self?.view?.setPayButtonTitle(Strings.Part.Active.Button.title)
                } else {
                    self?.view?.setPayButtonTitle(Strings.Pay.title)
                }
            }
            .store(in: &cancellable)
    }
    
    private func configViews() {
        
        switch vcMode {
        case .pay, .helper:
            view?.setPayButtonTitle(Strings.Pay.title)
        case .connect:
            view?.setPayButtonTitle(Strings.Connect.title)
        case .partPay:
            view?.setPayButtonTitle(Strings.Part.Active.Button.title)
        }
    }
    
    private func validatePayError(_ error: PayError) async {
        
        switch error {
            
        case .noInternetConnection:
            
            self.completionManager.completeWithError(SDKError(.errorSystem))
            
            let result = await alertService.show(on: view?.contentParrent, type: .noInternet)
            
            switch result {
            case .approve:
                
                await self.goToPay()
            case .cancel:
                
                await self.completionManager.dismissCloseAction(view?.contentParrent)
            }
        case .timeOut, .unknownStatus:
            
            configForWaiting()
        case .partPayError:
            
            let result = await alertService.show(on: view?.contentParrent, type: .partPayError)
            
            switch result {
            case .approve:
                
                partPayService.bnplplanSelected = false
                partPayService.setEnabledBnpl(false, enabledLevel: .paymentToken)
                
                await self.goToPay()
            case .cancel:
                
                self.completionManager.completeWithError(SDKError(.errorSystem))
                
                await alertService.show(on: view?.contentParrent, type: .defaultError)
                
                await self.completionManager.dismissCloseAction(view?.contentParrent)
            }
        default:
            
            self.completionManager.completeWithError(SDKError(.errorSystem))
            
            await alertService.show(on: view?.contentParrent, type: .defaultError)
            
            await self.completionManager.dismissCloseAction(view?.contentParrent)
        }
    }
    
    private func configForWaiting() {
        
        self.completionManager.completePay(with: .waiting)
        let okButton = AlertButtonModel(title: Strings.Cancel.title,
                                        type: .full) { [weak self] in
            self?.completionManager.dismissCloseAction(self?.view?.contentParrent)
        }
        
        Task {
            
            await alertService.show(on: view?.contentParrent,
                                    with: Strings.Alert.Pay.No.Waiting.title,
                                    with: ConfigGlobal.localization?.payLoading ?? "",
                                    with: nil,
                                    with: nil,
                                    state: .success,
                                    buttons: [okButton])
            
            await self.view?.contentParrent?.hideLoading(animate: true)
        }
    }
    
    private func goToPay() async {
        
        do {
            await self.view?.contentParrent?.showLoading(with: Strings.Try.To.Pay.title, animate: false)
            await view?.contentParrent?.setUserInteractionsEnabled(false)

            switch sdkManager.payStrategy {
            case .auto, .manual:
                
                try await payWithPaymentToken()
            case .partPay, .withoutRefresh:
                
                try await payWithoutPaymentToken()
            }
        } catch {
            await view?.contentParrent?.setUserInteractionsEnabled()
            
            if let error = error as? PayError {
                await self.validatePayError(error)
            } else if let error = error as? SDKError {
                self.dismissWithError(error)
            }
        }
    }
    
    private func payWithPaymentToken() async throws {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        
        if otpService.otpRequired {
            
            try await createOTP()
        }
        
        await self.view?.contentParrent?.showLoading(with: Strings.Try.To.Pay.title, animate: false)
        
        let challengeState = try await secureChallengeService.challenge(paymentId: paymentId,
                                                                        isBnplEnabled: partPayService.bnplplanSelected)
        
        switch challengeState {
        case .review:
            
            let resolution = await getChallengeResolution()
            
            switch secureChallengeService.fraudMonСheckResult?.secureChallengeFactor {
            case .hint:
                try await payWithResolution(resolution: resolution)
            case .sms:
                try await self.createOTP()
                try await payWithResolution(resolution: resolution)
            case .none:
                showSecureError()
            }
        case .deny:
            showSecureError()
        case nil:
            try await payWithResolution(resolution: nil)
        }
    }
    
    private func payWithoutPaymentToken() async throws {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        
        let challengeResult = try await paymentService.tryToPayWithoutToken(paymentId: paymentId,
                                                                            isBnplEnabled: partPayService.bnplplanSelected,
                                                                            resolution: nil)
        
        secureChallengeService.fraudMonСheckResult = challengeResult
        
        switch challengeResult?.secureChallengeState {
        case .review:
            let resolution = await getChallengeResolution()
            
            switch secureChallengeService.fraudMonСheckResult?.secureChallengeFactor {
            case .hint:
                try await payWithResolution(resolution: resolution)
                await showPaySuccessResult()
            case .sms:
                try await self.createOTP()
                try await payWithResolution(resolution: resolution)
                await showPaySuccessResult()
            case .none:
                showSecureError()
            }
        case .deny:
            showSecureError()
        case nil:
            await showPaySuccessResult()
        }
    }
    
    private func payWithResolution(resolution: SecureChallengeResolution?) async throws {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        
        await self.view?.contentParrent?.showLoading()
        await view?.contentParrent?.setUserInteractionsEnabled(false)
        
        switch sdkManager.payStrategy {
            
        case .auto, .manual:
            try await paymentService.tryToPayWithToken(paymentId: paymentId,
                                                       isBnplEnabled: partPayService.bnplplanSelected,
                                                       resolution: resolution)
        case .partPay, .withoutRefresh:
            try await paymentService.tryToPayWithoutToken(paymentId: paymentId,
                                                          isBnplEnabled: partPayService.bnplplanSelected,
                                                          resolution: resolution)
        }
    
        await showPaySuccessResult()
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
        
        Task {
            await alertService.show(on: view?.contentParrent, type: .defaultError)
            await self.completionManager.dismissCloseAction(view?.contentParrent)
        }
    }
    
    private func showSecureError() {
        
        let formParameters = secureChallengeService.fraudMonСheckResult?.formParameters
        
        let returnButton = AlertButtonModel(title: formParameters?.buttonDeclineText ?? "",
                                            type: .full) { [weak self] in
            self?.completionManager.completeWithError(SDKError(.errorSystem))
            self?.completionManager.dismissCloseAction(self?.view?.contentParrent)
        }
        
        Task {
            
            await alertService.show(on: self.view?.contentParrent,
                                    with: formParameters?.header ?? "",
                                    with: formParameters?.textDecline ?? "",
                                    with: nil,
                                    with: nil,
                                    state: .failure,
                                    buttons: [returnButton])
            
            await completionManager.dismissCloseAction(view?.contentParrent)
        }
    }
    
    private func showPaySuccessResult() async {
        
        self.partPayService.bnplplanSelected = false
        self.completionManager.completePay(with: .success)
        await view?.contentParrent?.setUserInteractionsEnabled()

        if let user = self.userService.user {
            
            if user.orderInfo.orderAmount.amount != 0 {
                
                let finalCost = partPayService.bnplplanSelected
                ? partPayService.bnplplan?.graphBnpl?.parts.first?.amount
                : user.orderInfo.orderAmount.amount
                
                await alertService.show(on: self.view?.contentParrent,
                                        type: .paySuccess(amount: finalCost?.price(.RUB) ?? "",
                                                          shopName: user.merchantInfo.merchantName,
                                                          bonuses: userService.selectedCard?.precalculateBonuses))
                await completionManager.dismissCloseAction(view?.contentParrent)
            } else {
                
                await alertService.show(on: self.view?.contentParrent,
                                        type: .connectSuccess(card: userService.selectedCard?.cardNumber.card ?? ""))
                await completionManager.dismissCloseAction(view?.contentParrent)
            }
        }
        self.userService.clearData()
    }
}
