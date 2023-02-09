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

    weak var view: (IAuthVC & ContentVC)?
    
    init(_ router: AuthRouter,
         authService: AuthService,
         sdkManager: SDKManager,
         analytics: AnalyticsService,
         userService: UserService) {
        self.analytics = analytics
        self.router = router
        self.authService = authService
        self.sdkManager = sdkManager
        self.userService = userService
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
        view?.showLoading()
        userService.checkUserSession { [weak self] result in
            switch result {
            case .success(let result):
                if result.statusSession {
                    self?.router.presentPayment()
                } else {
                    self?.configAuthSettings()
                }
            case .failure(let error):
                self?.sdkManager.completionWithError(error: error)
                self?.view?.showAlert(with: .failure())
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
       view?.showLoading(with: text)
        openSberId()
    }
    
    private func openSberId() {
        authService.tryToAuth { [weak self] error in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.removeObserver()
            if let error = error {
                self.router.presentPayment()
                self.analytics.sendEvent(.BankAppAuthSuccess)
                self.sdkManager.completionWithError(error: error)
            } else {
                self.analytics.sendEvent(.BankAppAuthSuccess)
                self.router.presentPayment()
            }
        }
    }
    
    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        view?.hideLoading()
        showBanksStack()
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}
