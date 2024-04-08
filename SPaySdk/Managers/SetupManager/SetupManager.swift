//
//  SetupManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 26.02.2024.
//

import Foundation

final class SetupManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(AuthManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: SetupManager = DefaultSetupManager()
            return service
        }
    }
}

protocol SetupManager {
    
    var resultViewNeeded: Bool { get }
    func resultViewNeeded(_ value: Bool)
}

final class DefaultSetupManager: SetupManager {

    var resultViewNeeded = true
    
    func resultViewNeeded(_ value: Bool) {
        resultViewNeeded = value
    }
}
