//
//  HostManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.05.2023.
//

import Foundation

enum HostSettings {
    case main
    case getIp
    case sid
}

private enum Host: String {
    case sandBox = "https://ift.gate2.spaymentsplus.ru"
    case safepayonlineIft = "https://ift.safepayonline.ru"
    case mocker = "https://api.mocki.io/v2/071c7c55"
    case ift = "https://ift.gate1.spaymentsplus.ru"
    case psi = "https://psi.gate1.spaymentsplus.ru"
    case prom = "https://gate1.spaymentsplus.ru"
    case sidIft = "https://id-ift.sber.ru"
    case sidPsi = "https://id-psi.sber.ru"
    case sidProm = "https://id.sber.ru"
    
    var url: URL {
        URL(string: rawValue) ?? URL(string: "https://www.google.com/")!
    }
}

final class HostManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(HostManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: HostManager = DefaultHostManager(environmentManager: container.resolve(),
                                                          buildSettings: container.resolve())
            return service
        }
    }
}

protocol HostManager {
    func host(for settings: HostSettings) -> URL
}

final class DefaultHostManager: HostManager {
    
    func host(for settings: HostSettings) -> URL {

        switch settings {
        case .main:
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
        case .getIp:
            switch buildSettings.networkState {
            case .Mocker:
                return Host.mocker.url
            default:
                return URL(string: UserDefaults.schemas?.getIpUrl ?? "") ?? Host.safepayonlineIft.url
            }
        case .sid:
            switch buildSettings.networkState {
            case .Mocker:
                return Host.mocker.url
            case .Ift:
                return Host.sidIft.url
            case .Psi:
                return Host.sidPsi.url
            case .Prom:
                return Host.sidProm.url
            case .Local:
                return Host.mocker.url
            }
        }
    }

    private let environmentManager: EnvironmentManager
    private let buildSettings: BuildSettings
    
    init(environmentManager: EnvironmentManager, buildSettings: BuildSettings) {
        self.environmentManager = environmentManager
        self.buildSettings = buildSettings
    }
}
