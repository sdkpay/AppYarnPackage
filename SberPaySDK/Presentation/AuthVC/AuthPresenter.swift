//
//  AuthPresenter.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

protocol AuthPresenting {
    func viewDidLoad()
}

final class AuthPresenter: AuthPresenting {
    private let analytics: AnalyticsService
    private let router: AuthRouter
    private let authService: AuthService
    private let sdkManager: SDKManager
    private let userService: UserService
    private let alertService: AlertService

    weak var view: (IAuthVC & ContentVC)?
    
    init(_ router: AuthRouter,
         authService: AuthService,
         sdkManager: SDKManager,
         analytics: AnalyticsService,
         userService: UserService,
         alertService: AlertService) {
        self.analytics = analytics
        self.router = router
        self.authService = authService
        self.sdkManager = sdkManager
        self.userService = userService
        self.alertService = alertService
    }
    
    deinit {
        removeObserver()
    }
    
    func viewDidLoad() {
        analytics.sendEvent(.AuthViewAppeared)
        checkNewStart()
    }
    
    private func checkNewStart() {
        if sdkManager.newStart || userService.user == nil {
            configAuthSettings()
        } else {
            checkSession()
        }
    }
    
    private func checkSession() {
        view?.hideAlert()
        view?.showLoading()
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

        if authService.selectedBank == nil {
            showBanksStack()
        } else {
            getAccessSberPay()
        }
    }
    
    private func showBanksStack() {
        authService.removeSavedBank()
        view?.configBanksStack(selected: { [weak self] bank in
            self?.authService.selectBank(bank)
            self?.getAccessSberPay()
        })
        analytics.sendEvent(.BankAppsViewAppear)
    }
    
    private func getAccessSberPay() {
        let text = authService.selectedBank == .sber ? String.Loading.toSberTitle : String.Loading.toSbolTitle
        view?.hideAlert()
        view?.showLoading(with: text)
        openSberId()
    }
    
    private func openSberId() {
        authService.tryToAuth { [weak self] error in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.removeObserver()
            if let error = error {
                self.analytics.sendEvent(.BankAppAuthFailed)
                if error.represents(.noInternetConnection) {
                    self.alertService.show(on: self.view,
                                           type: .noInternet(retry: { self.getAccessSberPay() },
                                                             completion: { self.dismissWithError(error) }))
                } else {
                    self.alertService.show(on: self.view,
                                           type: .defaultError(completion: { self.dismissWithError(error) }))
                }
            } else {
                self.analytics.sendEvent(.BankAppAuthSuccess)
                self.router.presentPayment()
            }
        }
    }
    
    private func dismissWithError(_ error: SDKError) {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: error)
        })
    }
    
    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        view?.hideLoading()
        SBLogger.log(.userReturned)
        if authService.avaliableBanks.count > 1 {
            showBanksStack()
        } else {
            dismissWithError(.cancelled)
        }
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}
