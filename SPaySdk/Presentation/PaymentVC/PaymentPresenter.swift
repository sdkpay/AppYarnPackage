//
//  PaymentPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import Foundation
import UIKit

enum PaymentVCMode {
    case pay
    case helper
    case connect
}

enum PurchaseSection: Int, CaseIterable {
    case all
}

enum PaymentSection: Int, CaseIterable {
    case features
    case card
}

enum PaymentFeature: Int, CaseIterable {
    case bnpl
}

protocol PaymentPresenting: NSObject {
    
    var featureCount: Int { get }
    var levelsCount: Int { get }
    var purchaseInfoText: String? { get }
    var screenHeight: ScreenHeightState { get }
    func identifiresForPaymentSection(_ section: PaymentSection) -> [Int]
    func identifiresForPurchaseSection() -> [Int]
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel?
    func purchaseModel(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectPaymentItem(at indexPath: IndexPath)
    func viewDidLoad()
    func payButtonTapped()
    func cancelTapped()
    func profileTapped()
    func viewDidAppear()
    func viewDidDisappear()
    var needPayButton: Bool { get }
}

protocol PaymentPresentingInput: NSObject {
    
    func cardTapped()
    func partPayTapped()
    func goTo(url: String)
}

final class PaymentPresenter: NSObject, PaymentPresenting, PaymentPresentingInput {
    
    var purchaseInfoText: String? {
        
        paymentViewModel.purchaseInfoText
    }

    var featureCount: Int {
        
        paymentViewModel.featureCount
    }
    
    var screenHeight: ScreenHeightState {
        
        paymentViewModel.screenHeight
    }
    
    var levelsCount: Int {
        
        partPayService.bnplplan?.graphBnpl?.payments.count ?? 0
    }

    weak var view: (IPaymentMasterVC & ContentVC)?
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
    private var payAmountValidationManager: PayAmountValidationManager
    private var paymentViewModel: PaymentViewModel

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
         payAmountValidationManager: PayAmountValidationManager,
         featureToggle: FeatureToggleService,
         otpService: OTPService,
         timeManager: OptimizationCheсkerManager,
         paymentViewModel: PaymentViewModel) {
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
        self.payAmountValidationManager = payAmountValidationManager
        self.featureToggle = featureToggle
        self.paymentViewModel = paymentViewModel
        self.timeManager.startTraking()
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
        setHints()
    }

    func setHints() {
        
        view?.setHints(with: paymentViewModel.hintsText)
    }
    
    var needPayButton: Bool {
        
        paymentViewModel.payButton
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
    
    func identifiresForPaymentSection(_ section: PaymentSection) -> [Int] {
        
        paymentViewModel.identifiresForSection(section)
    }
    
    func identifiresForPurchaseSection() -> [Int] {
        
        paymentViewModel.identifiresForPurchaseSection()
    }
    
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        paymentViewModel.model(for: indexPath)
    }
    
    func purchaseModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let orderAmount = userService.user?.orderAmount else { return nil }
        
        return PurchaseModelFactory.build(indexPath,
                                          bnplPayment: partPayService.bnplplan?.graphBnpl?.payments ?? [],
                                          fullPayment: orderAmount,
                                          bnplplanSelected: partPayService.bnplplanSelected)
    }
    
    func partPayTapped() {
        
        router.presentPartPay { [weak self] in
            self?.configViews()
            self?.view?.reloadData()
            self?.showPartsViewifNeed()
        }
    }
    
    func goTo(url: String) {
        
        completionManager.dismissCloseAction(view)
        guard let url = bankManager.configUrl(path: url) else { return }
        router.openUrl(url: url)
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        paymentViewModel.didSelectPaymentItem(at: indexPath)
    }
    
   private func showPartsViewifNeed() {
       
        view?.showPartsView(partPayService.bnplplanSelected)
    }
    
    func profileTapped() {
        guard let user = userService.user else { return }
        router.openProfile(with: user.userInfo)
    }
    
    func cardTapped() {
        
        analytics.sendEvent(.TouchCard, with: screenEvent)
        
        guard userService.additionalCards else { return }
        guard let authMethod = authManager.authMethod else { return }
        
        guard !userService.getListCards else {
            presentListCards()
            return
        }
        
        switch authMethod {
        case .refresh:
            Task { @MainActor [biometricAuthProvider] in
                
                let result = await biometricAuthProvider.evaluate()
                
                switch result {
                case true:
                    self.analytics.sendEvent(.LСGoodBioAuth, with: self.screenEvent)
                    self.presentListCards()
                case false:
                    self.analytics.sendEvent(.LСFailBioAuth, with: self.screenEvent)
                    self.appAuth()
                }
            }
                
            case .bank, .sid:
                presentListCards()
            }
    }
    
    private func presentListCards() {
        
        guard let selectedCard = userService.selectedCard,
              let user = userService.user else { return }
        
        userService.getListCards = true
        
        let finalCost = partPayService.bnplplanSelected ? partPayService.bnplplan?.graphBnpl?.payments.first?.amount : user.orderAmount.amount
        
        Task { @MainActor in
            self.router.presentCards(cards: user.paymentToolInfo,
                                     cost: finalCost?.price(.RUB) ?? "",
                                     selectedId: selectedCard.paymentId,
                                     selectedCard: { [weak self] card in
                self?.view?.hideLoading(animate: true)
                self?.userService.selectedCard = card
                self?.view?.reloadData()
                self?.setHints()
            })
        }
    }
    
    @MainActor
    private func createOTP() async throws {
        
        view?.showLoading()
        try await otpService.creteOTP()
        
        try await withCheckedThrowingContinuation({( inCont: CheckedContinuation<Void, Error>) -> Void in
            
            DispatchQueue.main.async {
                self.router.presentOTPScreen(completion: {
                    inCont.resume()
                })
            }
        })
    }
    
    private func configViews() {
    
        guard let user = userService.user else { return }

        view?.configShopInfo(with: user.merchantName ?? "",
                             iconURL: user.logoUrl, 
                             purchaseInfoText: paymentViewModel.purchaseInfoText)
        view?.addSnapShot()
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
                self.presentListCards()
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

        do {
            
            if otpService.otpRequired {
                
                try await createOTP()
            }
            
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
                    try await self.createOTP()
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
        
        Task { @MainActor [alertService] in
            alertService.close()
        }
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
