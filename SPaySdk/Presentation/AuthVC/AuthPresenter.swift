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
    
    init(_ router: AuthRouter,
         authService: AuthService,
         sdkManager: SDKManager,
         completionManager: CompletionManager,
         analytics: AnalyticsService,
         userService: UserService,
         alertService: AlertService,
         bankManager: BankAppManager,
         contentLoadManager: ContentLoadManager,
         timeManager: OptimizationCheсkerManager,
         enviromentManager: EnvironmentManager) {
        self.analytics = analytics
        self.router = router
        self.authService = authService
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
        timeManager.endTraking(AuthVC.self.description()) { _ in 
//            analytics.sendEvent(.AuthViewAppeared, with: [$0])
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        checkNewStart()
    }
    
    private func checkNewStart() {
        view?.showLoading()
        analytics.sendEvent(.MAInit, with: "environment: \(enviromentManager.environment)")
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
        userService.checkUserSession { [weak self] result in
            switch result {
            case .success:
                self?.router.presentPayment()
            case .failure(let error):
                self?.completionManager.completeWithError(error)
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.checkSession() },
                                                              completion: { self?.dismissWithError(error) }))
                } else {
                    self?.configAuthSettings()
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
        router.presentBankAppPicker { [weak self] in
            self?.auth()
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
        authService.tryToGetSessionId { [weak self] result in
            switch result {
            case .success(let authMethod):
                switch authMethod {
                case .bank:
                    self?.appAuth()
                case .refresh:
                    self?.auth()
                }
            case .failure(let error):
                self?.validateAuthError(error: error)
            }
        }
    }
    
    private func appAuth() {
        if enviromentManager.environment == .sandboxWithoutBankApp {
            router.presentFakeScreen(completion: {
                self.auth()
                return
            })
        }
        
        if bankManager.selectedBank == nil {
            showBanksStack()
        } else {
            appAuthMethod()
        }
    }
    
    private func appAuthMethod() {
        authService.appAuth(completion: { [weak self] result in
            self?.removeObserver()
            switch result {
            case .success:
                self?.auth()
            case .failure(let error):
                self?.bankManager.selectedBank = nil
                self?.showBanksStack()
                if error.represents(.bankAppNotFound) {
                    self?.view?.hideLoading()
                } else {
                    self?.validateAuthError(error: error)
                }
            }
        })
    }
    
    private func auth() {
        authService.auth { [weak self] result in
            switch result {
            case .success:
                self?.loadPaymentData()
            case .failure(let error):
                self?.validateAuthError(error: error)
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
