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
    private let manager: SDKManager
    private let analytics: AnalyticsService

    weak var view: (IAuthVC & ContentVC)?
    
    init(manager: SDKManager, analytics: AnalyticsService) {
        self.manager = manager
        self.analytics = analytics
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
        if manager.selectedBank == nil {
            showBanksStack()
        } else {
            getAccessSberPay()
        }
    }
    
    private func showBanksStack() {
        manager.removeSavedBank()
        view?.configBanksStack(selected: { [weak self] bank in
            self?.manager.selectBank(bank)
            self?.getAccessSberPay()
        })
        analytics.sendEvent(.BankAppsViewAppear)
    }
    
    private func getAccessSberPay() {
        let text = manager.selectedBank == .sber ? String.Loading.toSberTitle : String.Loading.toSbolTitle
        view?.showLoading(with: text)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                // Запрос на получение authCode
                self?.openSberId()
                // Debug
             //   self?.presentPaymentVC()
            }
    }
    
    private func openSberId() {
        manager.tryToAuth { [weak self] error in
            guard let self = self else { return }
            self.removeObserver()
            if error != nil {
                // DEBUG
                self.presentPaymentVC()
//                self.view?.showAlert(with: .failure,
//                                     text: error?.description)
                self.analytics.sendEvent(.BankAppAuthFailed)
            } else {
                self.analytics.sendEvent(.BankAppAuthSuccess)
                self.presentPaymentVC()
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
    
    private func presentPaymentVC() {
        let vc = PaymentAssembly().createModule(manager: manager, analytics: analytics)
        view?.contentNavigationController?.pushViewController(vc, animated: true)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}
