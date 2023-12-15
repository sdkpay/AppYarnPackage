//
//  EnvironmentManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.05.2023.
//

import Foundation

final class EnvironmentManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(EnvironmentManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: EnvironmentManager = DefaultEnvironmentManager()
            return service
        }
    }
}

protocol EnvironmentManager {
    var environment: SEnvironment { get }
    func setEnvironment(_ environment: SEnvironment)
}

final class DefaultEnvironmentManager: EnvironmentManager {
    private(set) var environment: SEnvironment = .prod
    
    func setEnvironment(_ environment: SEnvironment) {
        self.environment = environment
    }
}
