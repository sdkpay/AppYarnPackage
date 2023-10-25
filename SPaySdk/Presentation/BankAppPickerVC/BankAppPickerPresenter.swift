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
    
    private var completion: Action?
    
    init(bankManager: BankAppManager,
         authService: AuthService,
         alertService: AlertService,
         completionManager: CompletionManager,
         completion: @escaping Action) {
        self.completion = completion
        self.alertService = alertService
        self.completionManager = completionManager
        self.authService = authService
        self.bankManager = bankManager
    }
    
    func viewDidLoad() {
        bankAppModels = bankManager.avaliableBanks.map({ BankAppCellModel(with: $0) })
        view?.setSubtilte(Strings.BankAppPicker.subtitle(Bundle.main.displayName ?? "None"))
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
        appAuthMethod()
    }
    
    private func checkTappedAppsCount() {
        if !bankAppModels.contains(where: { !$0.tapped }) {
            showErrorAlert()
        }
    }
    
    private func appAuthMethod() {
        authService.appAuth(completion: { [weak self] result in
            switch result {
            case .success:
                self?.removeObserver()
                self?.completion?()
                self?.view?.contentNavigationController?.popViewController(animated: true)
            case .failure:
                self?.bankManager.selectedBank = nil
                self?.checkTappedAppsCount()
                self?.view?.reloadTableView()
            }
        })
    }
    
    private func showErrorAlert() {
        let returnButton = AlertButtonModel(title: Strings.Return.title,
                                            type: .full) { [weak self] in
            self?.completionManager.dismissCloseAction(self?.view)
        }
        alertService.showAlert(on: self.view,
                               with: Strings.Alert.BankAppPicker.Error.title,
                               state: .failure,
                               buttons: [returnButton],
                               completion: {})
    }
    
    // Клиент сам перешел из приложения банка
    @objc
    private func applicationDidBecomeActive() {
        view?.reloadTableView()
    }
    
    private func findIndexPath(_ bankApp: BankApp) -> IndexPath? {
        guard let index = bankManager.avaliableBanks.firstIndex(where: { $0.link == bankApp.link }) else { return nil }
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
