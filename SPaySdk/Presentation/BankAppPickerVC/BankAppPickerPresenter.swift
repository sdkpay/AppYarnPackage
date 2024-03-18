//
//  BankAppPickerPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.10.2023.
//

import UIKit

protocol BankAppPickerPresenting {
    var bankAppCount: Int { get }
    func closeButtonDidTapped()
    func model(for indexPath: IndexPath) -> BankAppCellModel
    func didSelectRow(at indexPath: IndexPath)
    func viewWillAppear()
    func viewWillDissapear()
    func viewDidLoad()
}

final class BankAppPickerPresenter: BankAppPickerPresenting {
    
    var bankAppCount: Int {
        bankAppModels.count
    }
    
    private var bankAppModels: [BankAppCellModel] = []
    
    weak var view: (IBankAppPickerVC & ContentVC)?
    private var bankManager: BankAppManager
    private var authService: AuthService
    private let completionManager: CompletionManager
    private let alertService: AlertService
    private let analytics: AnalyticsService
    
    private var completion: Action?
    
    init(bankManager: BankAppManager,
         authService: AuthService,
         alertService: AlertService,
         analytics: AnalyticsService,
         completionManager: CompletionManager,
         completion: @escaping Action) {
        self.completion = completion
        self.alertService = alertService
        self.analytics = analytics
        self.completionManager = completionManager
        self.authService = authService
        self.bankManager = bankManager
    }
    
    func viewDidLoad() {
        bankAppModels = bankManager.avaliableBanks.map({ BankAppCellModel(with: $0) })
        view?.setTilte(Strings.BankAppPicker.subtitle(Bundle.main.displayName))
        addObserver()
    }
    
    func model(for indexPath: IndexPath) -> BankAppCellModel {
        bankAppModels[indexPath.row]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        bankManager.selectedBank = bankManager.avaliableBanks[indexPath.row]
        bankAppModels.indices.forEach({ bankAppModels[$0].deprecated = false })
        bankAppModels[indexPath.row].deprecated = true
        bankAppModels[indexPath.row].tapped = true
        analytics.sendEvent(.TouchBankApp,
                            with: screenEvent)
        appAuthMethod()
    }
    
    private func checkTappedAppsCount() {
        if !bankAppModels.contains(where: { !$0.tapped }) {
            showErrorAlert()
        }
    }
    
    func viewWillAppear() {
        analytics.sendEvent(.LCBankAppsViewAppeared, 
                            with: screenEvent)
    }
    
    func viewWillDissapear() {
        analytics.sendEvent(.LCBankAppsViewDisappeared,
                            with: screenEvent)
    }

    private func appAuthMethod() {
        Task { @MainActor [view] in
            do {
                try await authService.appAuth()
                removeObserver()
                completion?()
                view?.contentNavigationController?.popViewController(animated: true)
            } catch {
                analytics.sendEvent(.LCBankAppOpenFail,
                                    with: screenEvent)
                bankManager.selectedBank = nil
                checkTappedAppsCount()
                view?.reloadTableView()
            }
        }
    }
    
    private func showErrorAlert() {
        
        let returnButton = AlertButtonModel(title: Strings.Common.Return.title,
                                            type: .info, 
                                            neededResult: .cancel) { [weak self] in
            
            self?.completionManager.dismissCloseAction(self?.view)
        }
        
        Task {
            
            await alertService.show(on: self.view,
                                    with: Strings.Alert.BankAppPicker.title,
                                    with: Strings.Alert.BankAppPicker.subtitle,
                                    with: nil,
                                    with: nil,
                                    state: .warning,
                                    buttons: [returnButton])
            
            completionManager.dismissCloseAction(view)
        }
    }
    
    // Клиент сам перешел из приложения банка
    @objc
    private func applicationDidBecomeActive() {
        SBLogger.log("📲 Become active without redirect")
        view?.reloadTableView()
        checkTappedAppsCount()
    }
    
    private func findIndexPath(_ bankApp: BankApp) -> IndexPath? {
        guard let index = bankManager.avaliableBanks.firstIndex(where: { $0.authLink == bankApp.authLink }) else { return nil }
        return IndexPath(index: index)
    }
    
    func closeButtonDidTapped() {
        completionManager.dismissCloseAction(view)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}
