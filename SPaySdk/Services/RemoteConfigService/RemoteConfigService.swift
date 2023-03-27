//
//  RemoteConfigService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.03.2023.
//

import Foundation

final class RemoteConfigServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: RemoteConfigService = DefaultRemoteConfigService(network: container.resolve())
        container.register(service: service)
    }
}

protocol RemoteConfigService {
    func getConfig()
}

final class DefaultRemoteConfigService: RemoteConfigService {
    private let network: NetworkService
    
    init(network: NetworkService) {
        self.network = network
    }
    
    func getConfig() {
        network.request(ConfigTarget.getConfig,
                        to: ConfigModel.self,
                        retryCount: 5) { [weak self] result in
            switch result {
            case .success(let config):
                self?.saveConfig(config)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func saveConfig(_ value: ConfigModel) {
        UserDefaults.localization = value.localization
        UserDefaults.schemas = value.schemas
        UserDefaults.images = value.images
    }
}
