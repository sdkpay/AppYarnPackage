//
//  HostManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.05.2023.
//

import Foundation

final class HostManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: HostManager = DefaultHostManager(environmentManager: container.resolve(),
                                                          buildSettings: container.resolve())
            return service
        }
    }
}

protocol HostManager {
    var host: URL { get }
}

final class DefaultHostManager: HostManager {
    var host: URL {
        guard environmentManager.environment == .prod else {
            return URL(string: "https://ift.gate2.spaymentsplus.ru/sdk-gateway/v1")!
        }
        
        switch buildSettings.networkState {
        case .Mocker:
            return URL(string: "https://ucexvyy1j5.api.quickmocker.com")!
        case .Ift:
            return URL(string: "https://ift.gate1.spaymentsplus.ru/sdk-gateway/v1")!
        case .Prom:
            return URL(string: "https://prom.gate1.spaymentsplus.ru/sdk-gateway/v1")!
        case .Psi:
            return URL(string: "https://psi.gate1.spaymentsplus.ru/sdk-gateway/v1")!
        case .Local:
            return URL(string: "https://psi.gate1.spaymentsplus.ru/sdk-gateway/v1")!
        }
    }
    
    private let environmentManager: EnvironmentManager
    private let buildSettings: BuildSettings
    
    init(environmentManager: EnvironmentManager, buildSettings: BuildSettings) {
        self.environmentManager = environmentManager
        self.buildSettings = buildSettings
    }
}
