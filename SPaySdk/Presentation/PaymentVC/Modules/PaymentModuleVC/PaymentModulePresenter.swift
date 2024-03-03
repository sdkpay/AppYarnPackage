//
//  PayPaymentModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.03.2024.
//

import UIKit

enum PaymentSection: Int, CaseIterable {
    case features
    case card
}

enum PaymentFeature: Int, CaseIterable {
    case bnpl
}

protocol PaymentModulePresenting: NSObject {
    
    var featureCount: Int { get }
    func identifiresForPaymentSection(_ section: PaymentSection) -> [Int]
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectPaymentItem(at indexPath: IndexPath)
    func viewDidLoad()
    func payButtonTapped()
    func cancelTapped()
    var payButtonText: String? { get }
    
    var view: (IPaymentModuleVC & ModuleVC)? { get set }
}


final class PaymentModulePresenter: NSObject, PaymentModulePresenting {

    private var activeFeatures = [PaymentFeature]()
    
    var featureCount: Int {
        
        activeFeatures.count
    }
    
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
    private var payAmountValidationManager: PayAmountValidationManager
    
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
        self.payAmountValidationManager = payAmountValidationManager
        self.featureToggle = featureToggle
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
        setHints()
    }
    
    func setHints() {
        
        view?.setHints(with: hintsText)
    }
    
    var payButtonText: String? {
        
        Strings.Pay.title
    }
    
    func payButtonTapped() {
        analytics.sendEvent(.TouchPay, with: screenEvent)
        
        Task {
            await goToPay()
        }
    }
    
    func cancelTapped() {
        
        self.completionManager.dismissCloseAction(view?.contentParrent)
    }
    
    func identifiresForPaymentSection(_ section: PaymentSection) -> [Int] {
        
        if partPayService.bnplplanSelected,
           let dates = partPayService.bnplplan?.graphBnpl?.payments.map({ $0.date }) {
            return dates.map { $0.hash }
        } else {
            return [.zero]
        }
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .card:
            cardTapped()
        case .features:
            partPayTapped()
        }
    }
    
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
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
    
    private func partPayTapped() {
        
        router.presentPartPay { [weak self] in
            self?.configViews()
            self?.view?.reloadData()
        }
    }
    
    private func configFeatures() {
        
        var features = [PaymentFeature]()
        
        if partPayService.bnplplanEnabled {
            features.append(.bnpl)
        }
        
        activeFeatures = features
    }
    
    func goTo(url: String) {
        
        completionManager.dismissCloseAction(view?.contentParrent)
        guard let fullUrl = bankManager.configUrl(path: url, type: .util) else { return }
        
        Task {
            
           let result = await router.open(fullUrl)
            
            if !result {
                
                router.presentBankAppPicker {
                    self.goTo(url: url)
                }
            }
        }
    }

   private func cardTapped() {
        
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
                
                let canEvalute = await biometricAuthProvider.canEvalute()
                
                switch canEvalute {
                case true:
                    let result = await biometricAuthProvider.evaluate()
                    
                    switch result {
                    case true:
                        self.analytics.sendEvent(.LСGoodBioAuth, with: self.screenEvent)
                        self.presentListCards()
                    case false:
                        self.analytics.sendEvent(.LСFailBioAuth, with: self.screenEvent)
                        self.appAuth()
                    }
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
        
        Task {
            
            do {
                
                await view?.contentParrent?.showLoading()
                try await userService.getListCards()
                
                guard let selectedCard = userService.selectedCard,
                      let user = userService.user else { return }
                
                userService.getListCards = true
                
                let finalCost = partPayService.bnplplanSelected
                ? partPayService.bnplplan?.graphBnpl?.payments.first?.amount
                : user.orderInfo.orderAmount.amount
                
                await MainActor.run {
                    self.router.presentCards(cards: user.paymentToolInfo.paymentTool,
                                             cost: finalCost?.price(.RUB) ?? "",
                                             selectedId: selectedCard.paymentID,
                                             selectedCard: { [weak self] card in
                        self?.view?.contentParrent?.hideLoading(animate: true)
                        self?.userService.selectedCard = card
                        self?.view?.reloadData()
                        self?.setHints()
                    })
                }
            } catch {
                await alertService.show(on: view?.contentParrent, type: .defaultError)
                
                if let error = error as? SDKError {
                    dismissWithError(error)
                }
            }
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
    
    private func configViews() {
        
        guard let user = userService.user else { return }
        
        view?.addSnapShot()
    }
    
    private func validatePayError(_ error: PayError) async {
        
        switch error {
            
        case .noInternetConnection:
            
            self.completionManager.completeWithError(SDKError(.errorSystem))
            
            let result = await alertService.show(on: view?.contentParrent, type: .noInternet)
            
            switch result {
            case .approve:
                
                self.pay(resolution: nil)
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
                                    state: .success,
                                    buttons: [okButton])
            
            await self.view?.contentParrent?.hideLoading(animate: true)
        }
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
                
                await self.view?.contentParrent?.showLoading()
                await NotificationCenter.default.removeObserver(self,
                                                                name: UIApplication.didBecomeActiveNotification,
                                                                object: nil)
                
                self.analytics.sendEvent(.LCBankAppAuthGood, with: self.screenEvent)
                
                repeatAuth()
            } catch {
                if let error = error as? SDKError {
                    
                    self.analytics.sendEvent(.LCBankAppAuthFail, with: self.screenEvent)
                    
                    if error.represents(.noData) {
                        
                        await MainActor.run {
                            router.presentBankAppPicker {
                                self.repeatAuth()
                            }
                        }
                    } else {
                        await alertService.show(on: view?.contentParrent, type: .defaultError)
                        dismissWithError(error)
                    }
                }
            }
        }
    }
    
    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        
        Task {
            await MainActor.run {
                router.presentBankAppPicker {
                    self.repeatAuth()
                }
            }
        }
    }
    
    private func repeatAuth() {
        Task {
          
            try await self.authService.auth()
            
            self.authService.bankCheck = true
            self.presentListCards()
        }
    }
    
    private func goToPay() async {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        
        do {
            
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
                await self.validatePayError(error)
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
                                    state: .failure,
                                    buttons: [returnButton])
            
            await completionManager.dismissCloseAction(view?.contentParrent)
        }
    }
    
    private func pay(resolution: SecureChallengeResolution?) {
        
        guard let paymentId = userService.selectedCard?.paymentID else { return }
        
        Task {
            await self.view?.contentParrent?.showLoading()
            await view?.contentParrent?.setUserInteractionsEnabled(false)
            do {
                try await paymentService.tryToPay(paymentId: paymentId,
                                                  isBnplEnabled: partPayService.bnplplanSelected,
                                                  resolution: resolution)
                self.partPayService.bnplplanSelected = false
                self.completionManager.completePay(with: .success)
                await view?.contentParrent?.setUserInteractionsEnabled()

                if let user = self.userService.user {
                    
                    if user.orderInfo.orderAmount.amount != 0 {
                        
                        let finalCost = partPayService.bnplplanSelected
                        ? partPayService.bnplplan?.graphBnpl?.payments.first?.amount
                        : user.orderInfo.orderAmount.amount
                        
                        await alertService.show(on: self.view?.contentParrent,
                                                type: .paySuccess(amount: finalCost?.price(.RUB) ?? "",
                                                                  shopName: user.merchantInfo.merchantName))
                        await completionManager.dismissCloseAction(view?.contentParrent)
                    } else {
                        
                        await alertService.show(on: self.view?.contentParrent,
                                                type: .connectSuccess(card: userService.selectedCard?.cardNumber.card ?? ""))
                        await completionManager.dismissCloseAction(view?.contentParrent)
                    }
                }
                self.userService.clearData()
            } catch {
                self.userService.clearData()
                self.partPayService.bnplplanSelected = false
                await view?.contentParrent?.setUserInteractionsEnabled()
                
                if let error = error as? PayError {
                    await validatePayError(error)
                } else if let error = error as? SDKError {
                    self.dismissWithError(error)
                }
            }
        }
    }
    
    private var hintsText: [String] {
        
        guard let tool = userService.selectedCard else { return [] }
        
        var hints = [String]()
        
        if let connectHint = connectIfNeeded() {
            
            hints.append(connectHint)
        }
        
        let payAmountStatus = try? payAmountValidationManager.checkAmountSelectedTool(tool)
        
        switch payAmountStatus {
            
        case .enouth, .none:
            
            return hints
        case .onlyBnpl:
            
            hints.append(Strings.Hints.Bnpl.title)
        case .notEnouth:
            
            hints.append(Strings.Hints.NotEnouth.title)
        }
        
        return hints
    }
    
    private func connectIfNeeded() -> String? {
        
        guard let merchantInfo = userService.user?.merchantInfo else { return nil }
        guard merchantInfo.bindingIsNeeded else { return nil }
        
        return merchantInfo.bindingSafeText
    }
}
