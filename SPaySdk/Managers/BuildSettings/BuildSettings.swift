//
//  BuildSettings.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

public enum NetworkState: String, CaseIterable, Codable {
    case Mocker = "Моккер", Prom = "ПРОМ", Ift = "ИФТ", Psi = "ПСИ", Local = "СТАБЫ"
}

final class BuildSettingsAssembly: Assembly {
    
    var type = ObjectIdentifier(BuildSettings.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: BuildSettings = DefaultBuildSettings()
            return service
        }
    }
}

protocol BuildSettings {
    var networkState: NetworkState { get }
    var ssl: Bool { get }
    var refresh: Bool { get }
    func setConfig(networkState: NetworkState, ssl: Bool, refresh: Bool)
}

final class DefaultBuildSettings: BuildSettings {
    private(set) var networkState = NetworkState.Prom
    private(set) var ssl = true
    private(set) var refresh = true
    
    func setConfig(networkState: NetworkState, ssl: Bool, refresh: Bool) {
        self.networkState = networkState
        self.ssl = ssl
        self.refresh = refresh
    }
}
