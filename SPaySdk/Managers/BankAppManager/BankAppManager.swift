//
//  BankAppManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 20.04.2023.
//

import UIKit
import Combine

extension MetricsValue {
    
    static let bankApp = MetricsValue(rawValue: "BankApp")
}

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
    var bankAppSavedPublisher: Published<BankApp?>.Publisher { get }
    var avaliableBanks: [BankApp] { get }
    func configUrl(path: String, type: BankUrlType) -> URL?
    func saveSelectedBank()
    func removeSavedBank()
}
 
final class DefaultBankAppManager: BankAppManager {

    var avaliableBanks: [BankApp] {
        UserDefaults.bankApps ?? []
    }
    
    private let analytics: AnalyticsManager
    
    init(analytics: AnalyticsManager) {
        self.analytics = analytics
    }
    
    private var _selectedBank: BankApp?
    
    @Published private var bankAppSaved: BankApp?
    
    var bankAppSavedPublisher: Published<BankApp?>.Publisher { $bankAppSaved }
    
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
        analytics.send(EventBuilder()
            .with(base: .ST)
            .with(action: .Remove)
            .with(value: .bankApp)
            .build(),
                       values: [.Value: _selectedBank?.name ?? "None"])
        UserDefaults.removeValue(for: .selectedBank)
    }
    
    func saveSelectedBank() {
        analytics.send(EventBuilder()
            .with(base: .ST)
            .with(action: .Save)
            .with(value: .bankApp)
            .build(),
                       values: [.Value: _selectedBank?.name ?? "None"])
        UserDefaults.bankApp = _selectedBank?.appId
        bankAppSaved = _selectedBank
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
                _selectedBank = UserDefaults.bankApps?.first(where: { $0.appId == savedBank })
                
                analytics.send(EventBuilder()
                    .with(base: .ST)
                    .with(action: .Get)
                    .with(state: .Good)
                    .with(value: .bankApp)
                    .build(),
                               values: [.Value: _selectedBank?.name ?? "None"])
                return _selectedBank
            } else {
                analytics.send(EventBuilder()
                    .with(base: .ST)
                    .with(action: .Get)
                    .with(state: .Fail)
                    .with(value: .bankApp)
                    .build())
                return nil
            }
        } else {
            // Берем единственный банк на устройстве
            _selectedBank = avaliableBanks.first
            return _selectedBank
        }
    }
}
