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
    private let analytics: AnalyticsService
    private let router: AuthRouter
    private let authService: AuthService
    private let sdkManager: SDKManager
    private let userService: UserService
    private var bankManager: BankAppManager
    private let alertService: AlertService
    private let timeManager: OptimizationCheсkerManager
    private let contentLoadManager: ContentLoadManager

    weak var view: (IAuthVC & ContentVC)?
    
    init(_ router: AuthRouter,
         authService: AuthService,
         sdkManager: SDKManager,
         analytics: AnalyticsService,
         userService: UserService,
         alertService: AlertService,
         bankManager: BankAppManager,
         contentLoadManager: ContentLoadManager,
         timeManager: OptimizationCheсkerManager) {
        self.analytics = analytics
        self.router = router
        self.authService = authService
        self.sdkManager = sdkManager
        self.userService = userService
        self.alertService = alertService
        self.contentLoadManager = contentLoadManager
        self.bankManager = bankManager
        self.timeManager = timeManager
        self.timeManager.startTraking()
    }
    
    deinit {
        removeObserver()
    }
    
    func viewDidLoad() {
        timeManager.endTraking(AuthVC.self.description()) {
            analytics.sendEvent(.AuthViewAppeared, with: [$0])
        }
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
        DispatchQueue.main.async {  [weak self] in
            guard let self = self else { return }
            self.view?.hideAlert()
            self.view?.showLoading(animate: false)
        }
       
        userService.checkUserSession { [weak self] result in
            switch result {
            case .success:
                self?.view?.showViews(false)
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

        if bankManager.selectedBank == nil {
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
        analytics.sendEvent(.BankAppsViewAppear)
    }
    
    private func getAccessSPay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.hideAlert()
            let title: String = .Loading.toBankTitle(args: self.bankManager.selectedBank?.name ?? "")
            self.view?.showLoading(with: title)
        }
       
        openSId()
    }
    
    private func openSId() {
        authService.tryToAuth { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.hideLoading()
            }
            self.removeObserver()
            if let error = error {
                self.analytics.sendEvent(.BankAppAuthFailed)
                if error.represents(.noInternetConnection) {
                    self.alertService.show(on: self.view,
                                           type: .noInternet(retry: { self.getAccessSPay() },
                                                             completion: { self.dismissWithError(error) }))
                } else {
                    self.alertService.show(on: self.view,
                                           type: .defaultError(completion: { self.dismissWithError(error) }))
                }
            } else {
                self.analytics.sendEvent(.BankAppAuthSuccess)
                self.loadPaymentData()
            }
        }
    }
    
    private func loadPaymentData() {
        view?.showLoading(with: .Loading.getData, animate: false)
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
                    self?.view?.showViews(false)
                    self?.router.presentPayment()
                }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
        }
        SBLogger.log(.userReturned)
        if bankManager.avaliableBanks.count > 1 {
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
