//
//  BankAppManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 20.04.2023.
//

import UIKit

final class BankAppManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(BankAppManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: BankAppManager = DefaultBankAppManager(analytics: container.resolve())
            return service
        }
    }
}

protocol BankAppManager {
    
    var selectedBank: BankApp? { get set }
    var avaliableBanks: [BankApp] { get }
    func configUrl(path: String, type: BankUrlType) -> URL?
    func saveSelectedBank()
    func removeSavedBank()
}
 
final class DefaultBankAppManager: BankAppManager {

    var avaliableBanks: [BankApp] {
        UserDefaults.bankApps ?? []
    }
    
    private let analytics: AnalyticsService
    
    init(analytics: AnalyticsService) {
        self.analytics = analytics
    }
    
    private var _selectedBank: BankApp?
    
    var selectedBank: BankApp? {
        get {
            if let bankApp = getSelectedBank() {
                return bankApp
            } else {
                return nil
            }
        } set {
            _selectedBank = newValue
        }
    }
    
    func removeSavedBank() {
        SBLogger.log("🗑 Remove value for key: selectedBank")
        UserDefaults.removeValue(for: .selectedBank)
    }
    
    func saveSelectedBank() {
        analytics.sendEvent(.STSaveBankApp,
                            with: [.view: AnlyticsScreenEvent.AuthVC.rawValue])
        UserDefaults.bankApp = _selectedBank?.name
    }
    
    func configUrl(path: String, type: BankUrlType) -> URL? {
        
        guard let link = selectedBank?.url(type: type) else { return nil }
        
        return URL(string: link + path)
    }
    
    private func getSelectedBank() -> BankApp? {
        // Проверяем есть ли выбранное приложение
        if let selectedBank = _selectedBank {
            return selectedBank
        }
        if avaliableBanks.count > 1 {
            // Если больше 1 то смотрим на сохраненный банк
            if let savedBank = UserDefaults.bankApp {
                _selectedBank = UserDefaults.bankApps?.first(where: { $0.name == savedBank })
                return _selectedBank
            } else {
                analytics.sendEvent(.STGetFailBankApp,
                                    with: [.view: AnlyticsScreenEvent.AuthVC.rawValue])
                return nil
            }
        } else {
            // Берем единственный банк на устройстве
            _selectedBank = avaliableBanks.first
            return _selectedBank
        }
    }
}
