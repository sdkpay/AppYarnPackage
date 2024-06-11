//
//  AuthPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

protocol AuthPresenting {
    func viewDidLoad()
    func viewDidDisappear()
    func webViewGoTo(url: URL)
}

final class AuthPresenter: AuthPresenting {
    
    weak var view: (IAuthVC & ContentVC)?
    
    private let analytics: AnalyticsManager
    private let router: AuthRouter
    private var authService: AuthService
    private let authManager: AuthManager
    private let completionManager: CompletionManager
    private let sdkManager: SDKManager
    private var userService: UserService
    private var bankManager: BankAppManager
    private let alertService: AlertService
    private let timeManager: OptimizationCheсkerManager
    private let enviromentManager: EnvironmentManager
    private let versionСontrolManager: VersionСontrolManager
    private let seamlessAuthService: SeamlessAuthService
    private var payAmountValidationManager: PayAmountValidationManager
    private var helperManager: HelperConfigManager
    private var featureToggle: FeatureToggleService
    private var partPayService: PartPayService
    private let remoteConfigService: RemoteConfigService
    private let biometricAuthProvider: BiometricAuthProviderProtocol
    
    private var authMethod: AuthMethod = .bank
    
    init(_ router: AuthRouter,
         authService: AuthService,
         seamlessAuthService: SeamlessAuthService,
         sdkManager: SDKManager,
         completionManager: CompletionManager,
         analytics: AnalyticsManager,
         userService: UserService,
         alertService: AlertService,
         bankManager: BankAppManager,
         versionСontrolManager: VersionСontrolManager,
         partPayService: PartPayService,
         timeManager: OptimizationCheсkerManager,
         enviromentManager: EnvironmentManager,
         remoteConfigService: RemoteConfigService,
         biometricAuthProvider: BiometricAuthProviderProtocol,
         payAmountValidationManager: PayAmountValidationManager,
         featureToggle: FeatureToggleService,
         authManager: AuthManager,
         helperManager: HelperConfigManager) {
        self.analytics = analytics
        self.router = router
        self.authService = authService
        self.versionСontrolManager = versionСontrolManager
        self.sdkManager = sdkManager
        self.completionManager = completionManager
        self.userService = userService
        self.alertService = alertService
        self.partPayService = partPayService
        self.bankManager = bankManager
        self.timeManager = timeManager
        self.enviromentManager = enviromentManager
        self.seamlessAuthService = seamlessAuthService
        self.payAmountValidationManager = payAmountValidationManager
        self.helperManager = helperManager
        self.authManager = authManager
        self.remoteConfigService = remoteConfigService
        self.featureToggle = featureToggle
        self.biometricAuthProvider = biometricAuthProvider
        self.timeManager.startTraking()
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func viewDidLoad() {
        
        Task {
            await startAuth()
        }
    }
    
    func viewDidDisappear() {}
    
    private func startAuth() async {
        
        guard !versionСontrolManager.isVersionDepicated else {
            
            await alertService.show(on: view,
                                    with: Strings.Error.Version.title,
                                    with: Strings.Error.Version.subtitle,
                                    with: nil,
                                    with: nil,
                                    state: .failure,
                                    buttons: [
                                        AlertButtonModel(title: Strings.Common.Return.title,
                                                         type: .info,
                                                         neededResult: .cancel,
                                                         action: { [weak self] in
                                                             self?.completionManager.dismissCloseAction(self?.view)
                                                         })
                                    ])
            return
        }
        
        do {
            try await getRemoteConfig()
            getSessiond()
        } catch {
            await alertService.show(on: view,
                                    type: .defaultError)
            dismissWithError(error.sdkError)
        }
    }
    
    @MainActor
    private func showBanksStack() {
        bankManager.removeSavedBank()
        Task {
            await router.presentBankAppPicker()
            await self.auth()
        }
    }
    
    private func getAccessSPay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.getSessiond()
        }
    }
    
    private func getRemoteConfig() async throws {
        
        try await remoteConfigService.getConfig()
    }
    
    private func getSessiond() {
        Task {
            do {
                let authMethod = try await authService.tryToGetSessionId()
                
                self.authMethod = authMethod
                
                switch authMethod {
                case .bank:
                    await appAuth()
                case .refresh:
                    await auth()
                case .sid:
                    await seamlessAuth()
                }
            } catch {
                if let error = error as? SDKError {
                    validateAuthError(error: error)
                }
            }
        }
    }
    
    private func appAuth() async {
        
        if enviromentManager.environment == .sandboxWithoutBankApp {
            await router.presentFakeScreen()
            await self.auth()
        }
        
        if bankManager.selectedBank == nil {
            await showBanksStack()
        } else {
            appAuthMethod()
        }
    }
    
    private func appAuthMethod() {
        Task {
            do {
                SBLogger.logThread(obj: self)
                try await authService.appAuth()
                SBLogger.logThread(obj: self)
                await auth()
            } catch {
                
                if error.sdkError.represents(.bankAppNotFound)
                    || error.sdkError.represents(.bankAppError) {
                    await showBanksStack()
                    await view?.hideLoading()
                } else {
                    validateAuthError(error: error.sdkError)
                }
            }
        }
    }
    
    private func auth() async {
        
        do {
            try await authService.auth()
            loadPaymentData()
        } catch {
            if authMethod == .refresh {
                await appAuth()
            } else if let error = error as? SDKError {
                validateAuthError(error: error)
            } else {
                validateAuthError(error: .init(.errorSystem))
            }
        }
    }
    
    private func seamlessAuth() async {
        do {
            let url = try await seamlessAuthService.getTransitTokenUrl()
            view?.goTo(url: url)
        } catch {
            await appAuth()
        }
    }
    
    func webViewGoTo(url: URL) {
        do {
            if try seamlessAuthService.isValideAuth(from: url) {
                Task {
                    await auth()
                }
            }
        } catch {
            Task {
                await appAuth()
            }
        }
    }
    
    private func getBnplPlan() async -> (error: SDKError?, type: ContentType) {
        
        let type = ContentType.bnpl
        
        let event = EventBuilder()
            .with(base: .LC)
            .with(value: .payBNPL)
        
        do {
            try await partPayService.getBnplPlan()
            
            if partPayService.bnplplanEnabled {
                event.with(postState: .Available)
            } else {
                event.with(postState: .Unavailable)
            }
            await analytics.send(event.build(), on: view?.analyticsName)
            return (nil, type)
        } catch {
            
            event.with(postState: .Unavailable)
            await analytics.send(event.build(), on: view?.analyticsName)
            return (error.sdkError, type)
        }
    }
    
    private func getUser() async -> (error: SDKError?, type: ContentType) {
        
        let type = ContentType.user
        
        do {
            
            try await userService.getUser()
            return (nil, type)
        } catch {
            return (error.sdkError, type)
        }
    }
    
    private enum ContentType {
        
        case user
        case bnpl
    }
    
    private func loadPaymentData() {
        
        Task {
            
            async let userError = await getUser()
            async let bnplError = await getBnplPlan()

            let errors = await [userError, bnplError]
            
            if sdkManager.payStrategy == .partPay {
                
                if let error = errors.first(where: { $0.type == .bnpl })?.error {
                    await alertService.show(on: view, type: .defaultError)
                    dismissWithError(error)
                    return
                }
                
                if !partPayService.bnplplanEnabled {
                    await alertService.show(on: view, type: .defaultError)
                    dismissWithError(.init(.errorSystem))
                    return
                }
            }
            
            if let error = errors.first(where: { $0.type == .user })?.error {
                
                if error.represents(.noInternetConnection) {
                    
                    let result = await alertService.show(on: view, type: .noInternet)
                    
                    switch result {
                    case .approve:
                        self.getAccessSPay()
                    case .cancel:
                        dismissWithError(error)
                    }
                } else {
                    await alertService.show(on: view, type: .defaultError)
                    dismissWithError(error)
                }
                return
            }
            
            guard let user = userService.user, !user.paymentToolInfo.paymentTool.isEmpty else {
                await self.router.presentHelper()
                return
            }
            
            if userService.selectedCard == nil {
                cardNeeded()
                return
            } else if let card = userService.selectedCard,
                      try payAmountValidationManager.checkWalletAmountEnouth() == .enouth,
                      try payAmountValidationManager.checkAmountSelectedTool(card) != .enouth {
                cardNeeded()
                return
            }
            
            if let user = userService.user, !user.paymentToolInfo.paymentTool.isEmpty {
                do {
                    let mode = try getPaymentMode()
                    await self.router.presentPayment(state: mode)
                } catch {
                    await alertService.show(on: view, type: .noMoney)
                    completionManager.dismissCloseAction(view)
                }
            } else {
                await self.router.presentHelper()
            }
        }
    }
    
    private func getPaymentMode() throws -> PaymentVCMode {
        
        if userService.user?.orderInfo.orderAmount.amount == 0 {
            return .connect
        }
        
        if sdkManager.payStrategy == .partPay {
            return .partPay
        }
        
        var status: PaymentVCMode
        
        switch try payAmountValidationManager.checkWalletAmountEnouth() {
        case .enouth: status = .pay
        case .notEnouth, .onlyBnpl: status = .helper
        }
        
        if status == .helper {
            
            if !helperManager.helpersNeeded || (!featureToggle.isEnabled(.newCreditCard) && (!featureToggle.isEnabled(.sbp))) {
                
                throw SDKError(.noMoney)
            }
        }
        
        return status
    }
    
    private func validateAuthError(error: SDKError) {
        
        Task {
            
            self.completionManager.completeWithError(error)
            if error.represents(.noInternetConnection) {
                
                let result = await alertService.show(on: view, type: .noInternet)
                
                switch result {
                case .approve:
                    self.getAccessSPay()
                case .cancel:
                    dismissWithError(error)
                }
            } else {
                await alertService.show(on: view, type: .defaultError)
                dismissWithError(error)
            }
        }
    }
    
    private func dismissWithError(_ error: SDKError) {
        completionManager.dismissCloseAction(view)
    }
    
    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        Task {
            await self.view?.hideLoading()
            SBLogger.log(.userReturned)
            if bankManager.avaliableBanks.count > 1 {
                await showBanksStack()
            } else {
                self.bankManager.selectedBank = nil
                self.completionManager.dismissCloseAction(view)
            }
        }
    }
    
    private func cardNeeded() {
         
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: .card)
            .build(), on: view?.analyticsName ?? .None)
         
         guard userService.additionalCards else { return }
         guard let authMethod = authManager.authMethod else { return }
         
        guard userService.firstCardUpdate else {
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
                         analytics.send(EventBuilder()
                             .with(base: .LC)
                             .with(state: .Good)
                             .with(value: .bioAuth)
                             .build(), on: view?.analyticsName ?? .None)
                         
                         self.presentListCards()
                     case false:
                         analytics.send(EventBuilder()
                             .with(base: .LC)
                             .with(state: .Fail)
                             .with(value: .bioAuth)
                             .build(), on: view?.analyticsName ?? .None)
                         await self.appAuth()
                     }
                 case false:
                     analytics.send(EventBuilder()
                         .with(base: .LC)
                         .with(state: .Fail)
                         .with(value: .bioAuth)
                         .build(), on: view?.analyticsName ?? .None)
                     await self.appAuth()
                 }
             }
             
         case .bank, .sid:
             
             presentListCards()
         }
     }
     
     private func presentListCards() {
         
         Task { @MainActor [view, router] in
             
             view?.showLoading()
             
             guard let selectedCard = userService.user?.paymentToolInfo.paymentTool.first?.paymentID,
                   let user = userService.user else { return }
              
             try await userService.getListCards()
    
             let card = try? await router.presentCards(cards: user.paymentToolInfo.paymentTool,
                                                       selectedId: selectedCard)
             view?.hideLoading(animate: true)
             userService.selectedCard = card
             
             if let user = userService.user, !user.paymentToolInfo.paymentTool.isEmpty {
                 do {
                     let mode = try getPaymentMode()
                     router.presentPayment(state: mode)
                 } catch {
                     await alertService.show(on: view, type: .noMoney)
                     completionManager.dismissCloseAction(view)
                 }
             } else {
                 router.presentHelper()
             }
         }
     }
     
     private func appAuth() {
         
         Task {
             do {
                 try await authService.appAuth()
                 
                 await self.view?.showLoading()
                 
                 repeatAuth()
             } catch {
                 if let error = error as? SDKError {
                     
                     if error.represents(.noData)
                         || error.represents(.bankAppError)
                         || error.represents(.bankAppNotFound) {
                         
                         await router.presentBankAppPicker()
                         self.repeatAuth()
                     } else {
                         await alertService.show(on: view, type: .defaultError)
                         completionManager.dismissCloseAction(view)
                     }
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
}
