//
//  HelperConfigManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 06.12.2023.
//

import Foundation

final class HelperConfigManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: HelperConfigManager = DefaultHelperConfigManager()
            return service
        }
    }
}

protocol HelperConfigManager {
    
    var config: SBHelperConfig { get }
    var helpersNeeded: Bool { get }
    func setConfig(_ config: SBHelperConfig)
    func setHelpersNeeded(_ value: Bool)
}

final class DefaultHelperConfigManager: HelperConfigManager {
    
    var config = SBHelperConfig()
    
    var helpersNeeded = true
    
    func setConfig(_ config: SBHelperConfig) {
        self.config = config
        checkHelpers()
    }
    
    func setHelpersNeeded(_ value: Bool) {
        self.helpersNeeded = value
        checkHelpers()
    }
    
    private func checkHelpers() {
        
        if !config.creditCard && !config.debitCard && !config.sbp {
            helpersNeeded = false
        }
    }
}
