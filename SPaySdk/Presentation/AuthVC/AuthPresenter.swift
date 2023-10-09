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
        checkNewStart()
    }
    
    private func checkNewStart() {
        analytics.sendEvent(.MAInit, with: "environment: \(enviromentManager.environment)")
        if enviromentManager.environment == .sandboxWithoutBankApp {
            checkSession()
        } else {
            if sdkManager.newStart || userService.user == nil {
                configAuthSettings()
            } else {
                checkSession()
            }
        }
    }
    
    private func checkSession() {
        DispatchQueue.main.async {  [weak self] in
            guard let self = self else { return }
            self.alertService.hide()
            self.view?.showLoading(animate: false)
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        if enviromentManager.environment == .sandboxWithoutBankApp {
            getAccessSPay()
        } else if bankManager.selectedBank == nil {
            showBanksStack()
        } else {
            getAccessSPay()
        }
    }
    
    private func showBanksStack() {
        bankManager.removeSavedBank()
        view?.configBanksStack(banks: bankManager.avaliableBanks, selected: { [weak self] bank in
            self?.bankManager.selectedBank = bank
            self?.getAccessSPay()
        })
//        analytics.sendEvent(.BankAppsViewAppear)
    }
    
    private func getAccessSPay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let title: String = Strings.To.Bank.title(self.bankManager.selectedBank?.name ?? "Банк")
            self.view?.showLoading(with: self.authService.tokenInStorage ? nil : title)
            self.openSId()
        }
    }
    
    private func openSId() {
        authService.tryToAuth { [weak self] error, isShowFakeScreen in
            guard let self = self else { return }
            self.removeObserver()
            if let error = error {
//                self.analytics.sendEvent(.BankAppAuthFailed)
                self.validateAuthError(error: error)
            } else {
                if isShowFakeScreen {
                    self.router.presentFakeScreen {
                        self.loadPaymentData()
                    }
                } else {
                    self.authService.refreshAuth { [weak self] result in
                        switch result {
                        case .success:
                            self?.loadPaymentData()
                        case .failure(let error):
//                            self?.analytics.sendEvent(.BankAppAuthFailed)
                            self?.validateAuthError(error: error)
                        }
                    }
                }
            }
        }
    }
    
    private func loadPaymentData() {
//        analytics.sendEvent(.BankAppAuthSuccess)
        view?.showLoading(with: Strings.Get.Data.title, animate: false)
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
