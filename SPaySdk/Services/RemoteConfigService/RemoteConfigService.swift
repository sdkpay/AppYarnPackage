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
    func getConfig(with apiKey: String, completion: @escaping (SDKError?) -> Void)
}

final class DefaultRemoteConfigService: RemoteConfigService {
    private let network: NetworkService
    private var apiKey: String?

    init(network: NetworkService) {
        self.network = network
    }
    
    func getConfig(with apiKey: String, completion: @escaping (SDKError?) -> Void) {
        self.apiKey = apiKey
        network.request(ConfigTarget.getConfig,
                        to: ConfigModel.self,
                        retryCount: 5) { [weak self] result in
            switch result {
            case .success(let config):
                self?.saveConfig(config)
                self?.checkWhiteLogList(apikeys: config.apikey)
                self?.checkVersion(version: config.version)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private func saveConfig(_ value: ConfigModel) {
        UserDefaults.localization = value.localization
        UserDefaults.schemas = value.schemas
        UserDefaults.images = value.images
    }
    
    private func checkWhiteLogList(apikeys: [String]) {
        guard let apiKey = apiKey else { return }
        RemoteConfig.shared.needLogs = apikeys.contains(apiKey)
    }
    
    private func checkVersion(version: String) {
        let currentVesion = Bundle.sdkVersion
        if version != currentVesion {
            SBLogger.log(level: .merchant, .MerchantAlert.alertVersion)
        }
    }
}
