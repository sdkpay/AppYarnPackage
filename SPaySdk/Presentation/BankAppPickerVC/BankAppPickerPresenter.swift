//
//  BankAppPickerPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.10.2023.
//

import UIKit
import Combine

protocol BankAppPickerPresenting {
    var bankAppCount: Int { get }
    func closeButtonDidTapped()
    func model(for indexPath: IndexPath) -> BankAppCellModel
    func didSelectRow(at indexPath: IndexPath)
    func debugBankTapped()
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
    private let analytics: AnalyticsManager
    
    private var completion: Action?

//    private var autoOpen = true
    private var index = 0
    
    init(bankManager: BankAppManager,
         authService: AuthService,
         alertService: AlertService,
         analytics: AnalyticsManager,
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
        bankAppModels = getModels(type: .prom)
        view?.setTilte(Strings.BankAppPicker.subtitle(Bundle.main.displayName))
        addObserver()
    }
    
    func model(for indexPath: IndexPath) -> BankAppCellModel {
        bankAppModels[indexPath.row]
    }
    
    func debugBankTapped() {
        
        let debugModels = getModels(type: .beta)
        
        guard let firstModel = debugModels.first else { return }
        if bankAppModels.contains(where: { $0.title == firstModel.title }) {
            bankAppModels = getModels(type: .prom)
        } else {
            bankAppModels.append(contentsOf: debugModels)
        }
        view?.reloadTableView()
    }

    func didSelectRow(at indexPath: IndexPath) {
        bankManager.selectedBank = bankManager.avaliableBanks[indexPath.row]
        bankAppModels.indices.forEach({ bankAppModels[$0].deprecated = false })
        bankAppModels[indexPath.row].deprecated = true
        bankAppModels[indexPath.row].tapped = true
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: .bankApp)
            .build(), on: view?.analyticsName ?? .None)
        appAuthMethod()
    }
    
    private func checkTappedAppsCount() {
        if !bankAppModels.contains(where: { !$0.tapped }) {
            showErrorAlert()
        }
    }
    
    private func getModels(type: BankApp.VersionType) -> [BankAppCellModel] {
        bankManager.avaliableBanks
            .filter({ $0.versionType == type })
            .map({ BankAppCellModel(with: $0) })
    }

    private func appAuthMethod() {
        Task { @MainActor [view] in
            do {
                try await authService.appAuth()
                analytics.send(EventBuilder()
                    .with(base: .LC)
                    .with(value: .bankApp)
                    .with(postState: .Good)
                    .build(), on: view?.analyticsName ?? .None)
                removeObserver()
                completion?()
                view?.contentNavigationController?.popViewController(animated: true)
            } catch {
                analytics.send(EventBuilder()
                    .with(base: .LC)
                    .with(postState: .Fail)
                    .build(), on: view?.analyticsName ?? .None)
                bankManager.selectedBank = nil
                checkTappedAppsCount()
                analytics.send(EventBuilder()
                    .with(base: .LC)
                    .with(value: .bankApp)
                    .with(postState: .Fail)
                    .build(), on: view?.analyticsName ?? .None)
                view?.reloadTableView()            }
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
        analytics.send(EventBuilder()
            .with(base: .LC)
            .with(value: .bankApp)
            .with(postAction: .Open)
            .with(postState: .Fail)
            .build(), on: view?.analyticsName ?? .None)
        removeObserver()
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
