//
//  BankAppManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 20.04.2023.
//

import UIKit

final class BankAppManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: BankAppManager = DefaultBankAppManager()
            return service
        }
    }
}

protocol BankAppManager {
    var selectedBank: BankApp? { get set }
    var avaliableBanks: [BankApp] { get }
    func saveSelectedBank()
    func removeSavedBank()
}
 
final class DefaultBankAppManager: BankAppManager {
    var avaliableBanks: [BankApp] {
        UserDefaults.bankApps?.filter({ canOpen(link: $0.link) }) ?? []
    }
    
    private var _selectedBank: BankApp?
    
    var selectedBank: BankApp? {
        get {
            if let bankApp = getSelectedBank(),
               canOpen(link: bankApp.link) {
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
        UserDefaults.bankApp = _selectedBank?.name
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
                return nil
            }
        } else {
            // Берем единственный банк на устройстве
            _selectedBank = avaliableBanks.first
            return _selectedBank
        }
    }
    
    private func canOpen(link: String) -> Bool {
        guard let url = URL(string: link) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
