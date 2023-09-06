//
//  AuthPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

protocol AuthPresenting {
    func viewDidLoad()
    func viewDidDissapear()
}

final class AuthPresenter: AuthPresenting {
    weak var view: (IAuthVC & ContentVC)?

    private let analytics: AnalyticsService
    private let router: AuthRouter
    private let authService: AuthService
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
    }
    
    func viewDidLoad() {
        checkNewStart()
        
        analytics.sendEvent(.LCBankAuthViewAppeared)
    }
    
    func viewDidDissapear() {
        if view?.bankCount ?? 0 > 1 {
            analytics.sendEvent(.LCBankAppsViewDisappeared, with: "orderNumber: \(self.sdkManager.authInfo?.orderNumber ?? "")")
        }
        
        analytics.sendEvent(.LCBankAuthViewDisappeared)
    }
    
    private func checkNewStart() {
        
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
            self?.analytics.sendEvent(.TouchBankApp, with: "orderNumber: \(self?.sdkManager.authInfo?.orderNumber ?? "")")
            self?.bankManager.selectedBank = bank
            self?.getAccessSPay()
        })
        if view?.bankCount ?? 0 > 1 {
            analytics.sendEvent(.LCBankAppsViewAppeared, with: "orderNumber: \(self.sdkManager.authInfo?.orderNumber ?? "")")
        }
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
                self.analytics.sendEvent(.LCBankAppAuthFail)
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
                            self?.analytics.sendEvent(.LCBankAppAuthFail)
                            self?.validateAuthError(error: error)
                        }
                    }
                }
            }
        }
    }
    
    private func loadPaymentData() {
        analytics.sendEvent(.LCBankAppAuthGood)
        view?.showLoading(with: Strings.Get.Data.title, animate: false)
        contentLoadManager.load { [weak self] error in
            if let error = error {
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
                self.alertService.show(on: self.view,
                                        type: .noInternet(retry: {
                    self.getAccessSPay()
                }, completion: {
                    self.dismissWithError(error)
                }))
            } else {
                self.alertService.show(on: self.view,
                                   type: .defaultError(completion: { self.dismissWithError(error) }))
            }
    }
    
    private func dismissWithError(_ error: SDKError) {
        alertService.close(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: error)
        })
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
            view?.dismiss(animated: true, completion: { [weak self] in
                self?.sdkManager.completionWithError(error: .cancelled)
            })
        }
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}
