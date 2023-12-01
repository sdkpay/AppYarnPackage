//
//  AuthPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

protocol AuthPresenting {
    func viewDidLoad()
    func webViewGoTo(url: URL)
}

final class AuthPresenter: AuthPresenting {
    
    weak var view: (IAuthVC & ContentVC)?

    private let analytics: AnalyticsService
    private let router: AuthRouter
    private var authService: AuthService
    private let completionManager: CompletionManager
    private let sdkManager: SDKManager
    private let userService: UserService
    private var bankManager: BankAppManager
    private let alertService: AlertService
    private let timeManager: OptimizationCheсkerManager
    private let contentLoadManager: ContentLoadManager
    private let enviromentManager: EnvironmentManager
    private let versionСontrolManager: VersionСontrolManager
    private let seamlessAuthService: SeamlessAuthService
    
    init(_ router: AuthRouter,
         authService: AuthService,
         seamlessAuthService: SeamlessAuthService,
         sdkManager: SDKManager,
         completionManager: CompletionManager,
         analytics: AnalyticsService,
         userService: UserService,
         alertService: AlertService,
         bankManager: BankAppManager,
         versionСontrolManager: VersionСontrolManager,
         contentLoadManager: ContentLoadManager,
         timeManager: OptimizationCheсkerManager,
         enviromentManager: EnvironmentManager) {
        self.analytics = analytics
        self.router = router
        self.authService = authService
        self.versionСontrolManager = versionСontrolManager
        self.sdkManager = sdkManager
        self.completionManager = completionManager
        self.userService = userService
        self.alertService = alertService
        self.contentLoadManager = contentLoadManager
        self.bankManager = bankManager
        self.timeManager = timeManager
        self.enviromentManager = enviromentManager
        self.seamlessAuthService = seamlessAuthService
        self.timeManager.startTraking()
    }
    
    deinit {
        removeObserver()
        SBLogger.log(.stop(obj: self))
    }
    
    func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        checkNewStart()
    }
    
    private func checkNewStart() {
        analytics.sendEvent(.MAInit, with: "environment: \(enviromentManager.environment)")
        
        guard !versionСontrolManager.isVersionDepicated else {
            alertService.showAlert(on: view,
                                   with: Strings.Error.Version.title,
                                   with: Strings.Error.Version.subtitle,
                                   with: nil,
                                   state: .failure,
                                   buttons: [
                                    AlertButtonModel(title: Strings.Return.title,
                                                     type: .info,
                                                     action: { [weak self] in
                                                         self?.completionManager.dismissCloseAction(self?.view)
                                                     })
                                   ]) { [weak self] in
                                       self?.completionManager.dismissCloseAction(self?.view)
                                   }
            return
        }
        
        if enviromentManager.environment == .sandboxWithoutBankApp {
            checkSession()
        } else {
            if sdkManager.newStart || userService.user == nil {
                getSessiond()
            } else {
                checkSession()
            }
        }
    }
    
    private func checkSession() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.view?.showLoading()
        }
        
        Task {
            do {
                try await userService.checkUserSession()
                await router.presentPayment()
            } catch {
                if let error = error as? SDKError {
                    completionManager.completeWithError(error)
                    if error.represents(.noInternetConnection) {
                        alertService.show(on: view,
                                          type: .noInternet(retry: { self.checkSession() },
                                                            completion: { self.dismissWithError(error) }))
                    } else {
                        await configAuthSettings()
                    }
                }
            }
        }
    }
    
    private func configAuthSettings() async {
        if enviromentManager.environment == .sandboxWithoutBankApp {
            getAccessSPay()
        } else if bankManager.selectedBank == nil {
            await MainActor.run { showBanksStack() }
        } else {
            getAccessSPay()
        }
    }

    @MainActor
    private func showBanksStack() {
        removeObserver()

         router.presentBankAppPicker {
             Task {
                 await self.auth()
             }
        }
    }
    
    private func getAccessSPay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.getSessiond()
        }
    }
    
    private func getSessiond() {
        Task {
            do {
                let authMethod = try await authService.tryToGetSessionId()

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
            await MainActor.run {  router.presentFakeScreen(completion: {
                Task {
                    await self.auth()
                    return
                }
            })}
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
                removeObserver()
                SBLogger.logThread(obj: self)
                await auth()
            } catch {
                if let error = error as? SDKError {
                    bankManager.selectedBank = nil
                    await showBanksStack()
                    if error.represents(.bankAppNotFound) {
                        await view?.hideLoading()
                    } else {
                        validateAuthError(error: error)
                    }
                    await self.auth()
                }
            }
        }
    }
    
    private func auth() async {
        
        do {
            try await authService.auth()
            loadPaymentData()
        } catch {
            bankManager.selectedBank = nil
            if let error = error as? SDKError {
                validateAuthError(error: error)
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
    
    private func loadPaymentData() {
        Task {
            await self.view?.showLoading(with: Strings.Get.Data.title, animate: true)
            
            do {
                try await contentLoadManager.load()
                 await self.router.presentPayment()
            } catch {
                if let error = error as? SDKError {
                    self.completionManager.completeWithError(error)
                    if error.represents(.noInternetConnection) {
                        self.alertService.show(on: self.view,
                                               type: .noInternet(retry: { self.loadPaymentData() },
                                                                 completion: { self.dismissWithError(error) }))
                    } else {
                        self.alertService.show(on: self.view,
                                               type: .defaultError(completion: { self.dismissWithError(error) }))
                    }
                }
            }
        }
    }
    
    private func validateAuthError(error: SDKError) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.view?.hideLoading()
        }
        if error.represents(.noInternetConnection) {
            alertService.show(on: view,
                              type: .noInternet(retry: {
                self.getAccessSPay()
            }, completion: {
                self.dismissWithError(error)
            }))
        } else {
            alertService.show(on: view,
                              type: .defaultError(completion: { self.dismissWithError(error) }))
        }
    }
    
    private func dismissWithError(_ error: SDKError) {
        self.completionManager.completeWithError(error)
        self.alertService.close()
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
                self.completionManager.dismissCloseAction(view)
            }
        }
    }

    private func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}
