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

    weak var view: (IAuthVC & ContentVC)?
    
    init(_ router: AuthRouter,
         authService: AuthService,
         sdkManager: SDKManager,
         analytics: AnalyticsService) {
        self.analytics = analytics
        self.router = router
        self.authService = authService
        self.sdkManager = sdkManager
    }
    
    deinit {
        removeObserver()
    }
    
    func viewDidLoad() {
        configAuthSettings()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    private func configAuthSettings() {
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
