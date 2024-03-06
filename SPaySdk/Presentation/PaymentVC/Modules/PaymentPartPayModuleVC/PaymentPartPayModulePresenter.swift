//
//  PaymentPartPayModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import UIKit
import Combine

protocol PaymentPartPayModulePresenting: NSObject {

    func payButtonTapped()
    func viewDidLoad()
    
    var view: (IPaymentPartPayModuleVC & ModuleVC)? { get set }
}

final class PaymentPartPayModulePresenter: NSObject, PaymentPartPayModulePresenting {
    
    weak var view: (IPaymentPartPayModuleVC & ModuleVC)?
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
    private let featureToggle: FeatureToggleService
    private var secureChallengeService: SecureChallengeService
    private let otpService: OTPService
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
         featureToggle: FeatureToggleService,
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
        self.bankManager = bankManager
        self.authManager = authManager
        self.featureToggle = featureToggle
        self.otpService = otpService
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
        
        partPayService.bnplCheckAcceptedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] checkState in
                self?.view?.setButtonEnabled(checkState)
            }
            .store(in: &cancellable)
    }
    
    private func configViews() {
        
        view?.setPayButtonTitle(Strings.Part.Active.Button.title)
    }
    
    private func validatePayError(_ error: PayError) async {
        
        switch error {
            
        case .noInternetConnection:
            
            self.completionManager.completeWithError(SDKError(.errorSystem))
            
            let result = await alertService.show(on: view?.contentParrent, type: .noInternet)
            
            switch result {
            case .approve:
                
                await goToPay()
            case .cancel:
                
                await self.completionManager.dismissCloseAction(view?.contentParrent)
            }
        case .timeOut, .unknownStatus:
            
            configForWaiting()
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
                                    with: userService.selectedCard?.precalculateBonuses,
                                    state: .success,
                                    buttons: [okButton])
            
            await self.view?.contentParrent?.hideLoading(animate: true)
        }
    }
    
    private func goToPay() async {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        await self.view?.contentParrent?.showLoading(with: Strings.Try.To.Pay.title, animate: false)
        await view?.contentParrent?.setUserInteractionsEnabled(false)
        
        do {
            
            let challengeResult = try await paymentService.tryToPayWithoutToken(paymentId: paymentId,
                                                                               isBnplEnabled: true,
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
        } catch {
            await view?.contentParrent?.setUserInteractionsEnabled()
            
            if let error = error as? PayError {
                await self.validatePayError(error)
            } else if let error = error as? SDKError {
                self.dismissWithError(error)
            }
        }
    }
    
    private func payWithResolution(resolution: SecureChallengeResolution?) async throws {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        
        try await paymentService.tryToPayWithoutToken(paymentId: paymentId,
                                                      isBnplEnabled: true,
                                                      resolution: resolution)
    }
    
    private func showPaySuccessResult() async {
        
        self.completionManager.completePay(with: .success)
        await view?.contentParrent?.setUserInteractionsEnabled()

        if let user = self.userService.user {
            
            if user.orderInfo.orderAmount.amount != 0 {
                
                let finalCost = partPayService.bnplplan?.graphBnpl?.parts.first?.amount
                
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
}
