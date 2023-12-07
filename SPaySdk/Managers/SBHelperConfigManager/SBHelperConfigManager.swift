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
    func setConfig(_ config: SBHelperConfig)
}

final class DefaultHelperConfigManager: HelperConfigManager {
    
    var config = SBHelperConfig()
    
    func setConfig(_ config: SBHelperConfig) {
        self.config = config
    }
}
