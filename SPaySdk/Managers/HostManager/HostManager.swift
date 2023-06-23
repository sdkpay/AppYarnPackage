//
//  HostManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.05.2023.
//

import Foundation

private enum Host: String {
    case sandBox = "https://ift.gate2.spaymentsplus.ru/sdk-gateway/v1"
    case mocker = "https://ucexvyy1j5.api.quickmocker.com"
    case ift = "https://ift.gate1.spaymentsplus.ru/sdk-gateway/v1"
    case psi = "https://psi.gate1.spaymentsplus.ru/sdk-gateway/v1"
    case prom = "https://prom.gate1.spaymentsplus.ru/sdk-gateway/v1"
    var url: URL {
        URL(string: rawValue) ?? URL(string: "https://www.google.com/")!
    }
}

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
            return Host.sandBox.url
        }
        
        switch buildSettings.networkState {
        case .Mocker:
            return Host.mocker.url
        case .Ift:
            return Host.ift.url
        case .Prom:
            return Host.prom.url
        case .Psi:
            return Host.psi.url
        case .Local:
            return Host.mocker.url
        }
    }
    
    private let environmentManager: EnvironmentManager
    private let buildSettings: BuildSettings
    
    init(environmentManager: EnvironmentManager, buildSettings: BuildSettings) {
        self.environmentManager = environmentManager
        self.buildSettings = buildSettings
    }
}
