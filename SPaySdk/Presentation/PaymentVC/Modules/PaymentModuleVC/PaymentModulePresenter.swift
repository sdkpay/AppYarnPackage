//
//  PaymentModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.03.2024.
//

import UIKit
import Combine

extension MetricsValue {
    
    static let payBNPL = MetricsValue(rawValue: "payBNPL")
    static let BNPL = MetricsValue(rawValue: "BNPL")
}

protocol PaymentModulePresenting: NSObject {

    func payButtonTapped()
    func viewDidLoad()
    
    var view: (IPaymentModuleVC & ModuleVC)? { get set }
}

final class PaymentModulePresenter: NSObject, PaymentModulePresenting {
    
    weak var view: (IPaymentModuleVC & ModuleVC)?
    private let router: PaymentRouting
    private let analytics: AnalyticsManager
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
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsManager,
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
        
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: MetricsValue(rawValue: "Pay"))
            .build(), on: view?.contentParrent?.analyticsName ?? .None)
        
        Task {
            await goToPay()
        }
    }

    @MainActor
    private func createOTP() async throws {
        
        try await otpService.creteOTP()
        await router.presentOTPScreen()
        self.view?.contentParrent?.showLoading()
    }
    
    private func setupPublishers() {
        
        if vcMode == .partPay {
            partPayService.bnplCheckAcceptedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] checkState in
                self?.view?.setButtonEnabled(checkState)
            }
            .store(in: &cancellable)
        }
    }
    
    private func configViews() {
        
        switch vcMode {
        case .pay, .helper:
            view?.setPayButtonTitle(Strings.Common.Pay.title)
        case .connect:
            view?.setPayButtonTitle(Strings.Common.Connect.title)
        case .partPay:
            view?.setPayButtonTitle(Strings.PartPay.Active.Button.title)
        }
    }
    
    private func validatePayError(_ error: PayError) async {
        
        switch error {
            
        case .noInternetConnection:
            
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
        let okButton = AlertButtonModel(title: Strings.Common.Cancel.title,
                                        type: .full, 
                                        neededResult: .approve) { [weak self] in
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
            await self.view?.contentParrent?.showLoading(animate: false)

            switch sdkManager.payStrategy {
            case .auto:
                
                try await payWithPaymentToken()
            case .partPay, .withoutRefresh:
                
                try await payWithoutPaymentToken()
            }
        } catch {
            await view?.contentParrent?.setUserInteractionsEnabled()
            
            if let error = error as? PayError {
                await self.validatePayError(error)
            } else if let error = error as? SDKError {
                
                if error.represents(.noInternetConnection) {
                    
                    let result = await alertService.show(on: view?.contentParrent, type: .noInternet)
                    
                    switch result {
                    case .approve:
                        await goToPay()
                    case .cancel:
                        self.completionManager.completeWithError(error)
                        await alertService.show(on: view?.contentParrent, type: .defaultError)
                        await self.completionManager.dismissCloseAction(view?.contentParrent)
                    }
                }
                self.dismissWithError(error)
            }
        }
    }
    
    private func payWithPaymentToken() async throws {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        
        if otpService.otpRequired {
            
            try await createOTP()
        }
        
        let challengeState = try await secureChallengeService.challenge(paymentId: paymentId,
                                                                        isBnplEnabled: partPayService.bnplplanSelected)
        
        if partPayService.bnplplanSelected {
            
            await analytics
                .send(EventBuilder()
                    .with(base: .LC)
                    .with(value: .payBNPL)
                    .with(postAction: .Start)
                    .build(),
                      on: view?.contentParrent?.analyticsName)
        }
        
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
        
        if partPayService.bnplplanSelected {
            await analytics
                .send(EventBuilder()
                    .with(base: .LC)
                    .with(value: .payBNPL)
                    .with(postAction: .Start)
                    .build(),
                      on: view?.contentParrent?.analyticsName)
        }
        
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
        
        switch sdkManager.payStrategy {
            
        case .auto:
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
        return try? await router.presentChallenge()
    }
    
    private func dismissWithError(_ error: SDKError) {
        
        Task {
            
            if error.represents(.noInternetConnection) {
                
                let result = await alertService.show(on: view?.contentParrent, type: .noInternet)
                
                switch result {
                case .approve:
                    await goToPay()
                case .cancel:
                    self.completionManager.completeWithError(error)
                    await alertService.show(on: view?.contentParrent, type: .defaultError)
                    await self.completionManager.dismissCloseAction(view?.contentParrent)
                }
            } else {
                self.completionManager.completeWithError(error)
                await alertService.show(on: view?.contentParrent, type: .defaultError)
                await self.completionManager.dismissCloseAction(view?.contentParrent)
            }
        }
    }
    
    private func showSecureError() {
        
        let formParameters = secureChallengeService.fraudMonСheckResult?.formParameters
        
        let returnButton = AlertButtonModel(title: formParameters?.buttonDeclineText ?? "",
                                            type: .full,
                                            neededResult: .cancel) { [weak self] in
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

        self.completionManager.completePay(with: .success)
        await view?.contentParrent?.setUserInteractionsEnabled()

        if let user = self.userService.user {
            
            if user.orderInfo.orderAmount.amount != 0 {
                
                let finalCost = partPayService.bnplplanSelected
                ? partPayService.bnplplan?.graphBnpl?.parts.first?.amount
                : user.orderInfo.orderAmount.amount
                
                let bonusesEnabled = featureToggle.isEnabled(.spasiboBonuses) && !partPayService.bnplplanSelected
                let bonuses = bonusesEnabled ? userService.selectedCard?.precalculateBonuses : nil
                
                await alertService.show(on: self.view?.contentParrent,
                                        type: .paySuccess(amount: finalCost?.price(.RUB) ?? "",
                                                          shopName: user.merchantInfo.merchantName,
                                                          bonuses: bonuses))
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
