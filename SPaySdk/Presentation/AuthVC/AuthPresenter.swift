//
//  AuthPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

protocol AuthPresenting {
    func viewDidLoad()
}

final class AuthPresenter: AuthPresenting {
    weak var view: (IAuthVC & ContentVC)?

    private let analytics: AnalyticsService
    private let router: AuthRouter
    private let authService: AuthService
    private let completionManager: CompletionManager
    private let sdkManager: SDKManager
    private let userService: UserService
    private var bankManager: BankAppManager
    private let alertService: AlertService
    private let timeManager: OptimizationCheсkerManager
    private let contentLoadManager: ContentLoadManager
    private let enviromentManager: EnvironmentManager
    private let versionСontrolManager: VersionСontrolManager
    
    init(_ router: AuthRouter,
         authService: AuthService,
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
        view?.showLoading()
        analytics.sendEvent(.MAInit, with: "environment: \(enviromentManager.environment)")
        
        guard !versionСontrolManager.isVersionDepicated else {
            alertService.showAlert(on: view,
                                   with: Strings.Error.version,
                                   state: .failure,
                                   buttons: [
                                    AlertButtonModel(title: Strings.Return.title,
                                                     type: .full,
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
                router.presentPayment()
            } catch {
                if let error = error as? SDKError {
                    completionManager.completeWithError(error)
                    if error.represents(.noInternetConnection) {
                        alertService.show(on: view,
                                          type: .noInternet(retry: { self.checkSession() },
                                                            completion: { self.dismissWithError(error) }))
                    } else {
                        configAuthSettings()
                    }
                }
            }
        }
    }
    
    private func configAuthSettings() {
        if enviromentManager.environment == .sandboxWithoutBankApp {
            getAccessSPay()
        } else if bankManager.selectedBank == nil {
            showBanksStack()
        } else {
            getAccessSPay()
        }
    }
    
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
            let title: String = Strings.To.Bank.title(self.bankManager.selectedBank?.name ?? "Банк")
            self.view?.showLoading(with: self.authService.tokenInStorage ? nil : title)
            self.getSessiond()
        }
    }
    
    private func getSessiond() {
        Task {
            do {
                let authMethod = try await authService.tryToGetSessionId()

                switch authMethod {
                case .bank:
                    appAuth()
                case .refresh:
                    await auth()
                }
            } catch {
                if let error = error as? SDKError {
                    validateAuthError(error: error)
                }
            }
        }
    }
    
    private func appAuth() {
        if enviromentManager.environment == .sandboxWithoutBankApp {
            router.presentFakeScreen(completion: {
                Task {
                    await self.auth()
                    return
                }
            })
        }
        
        if bankManager.selectedBank == nil {
            showBanksStack()
        } else {
            appAuthMethod()
        }
    }
    
    private func appAuthMethod() {
        Task {
            do {
                try await authService.appAuth()
                await auth()
            } catch {
                if let error = error as? SDKError {
                    bankManager.selectedBank = nil
                    showBanksStack()
                    if error.represents(.bankAppNotFound) {
                        await view?.hideLoading()
                    } else {
                        validateAuthError(error: error)
                    }
                }
            }
        }
    }
    
    private func auth() async {
        
        do {
            try await authService.auth()
            loadPaymentData()
        } catch {
            if let error = error as? SDKError {
                validateAuthError(error: error)
            }
        }
    }
    
    private func loadPaymentData() {
        view?.showLoading(with: Strings.Get.Data.title, animate: true)
        contentLoadManager.load { [weak self] error in
            if let error = error {
                self?.completionManager.completeWithError(error)
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.loadPaymentData() },
                                                              completion: { self?.dismissWithError(error) }))
                } else {
                    self?.alertService.show(on: self?.view,
                                            type: .defaultError(completion: { self?.dismissWithError(error) }))
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.router.presentPayment()
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
        }
        SBLogger.log(.userReturned)
        if bankManager.avaliableBanks.count > 1 {
            showBanksStack()
        } else {
            self.completionManager.dismissCloseAction(view)
        }
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}
