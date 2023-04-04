//
//  RemoteConfigService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.03.2023.
//

import Foundation

final class RemoteConfigServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: RemoteConfigService = DefaultRemoteConfigService(network: container.resolve(),
                                                                      analytics: container.resolve())
        container.register(service: service)
    }
}

protocol RemoteConfigService {
    func getConfig(with apiKey: String, completion: @escaping (SDKError?) -> Void)
}

final class DefaultRemoteConfigService: RemoteConfigService {
    private let network: NetworkService
    private let optimizationManager = OptimizationCheсkerManager()
    private var apiKey: String?
    private let analytics: AnalyticsService

    init(network: NetworkService, analytics: AnalyticsService) {
        self.network = network
        self.analytics = analytics
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
        optimizationManager.checkSavedDataSize(object: value) {
            self.analytics.sendEvent(.DataSize, with: [$0])
        }
        UserDefaults.localization = value.localization
        UserDefaults.schemas = value.schemas
        UserDefaults.images = value.images
    }
    
    private func checkWhiteLogList(apikeys: [String]) {
        // guard let apiKey = apiKey else { return }
        // DEBUG
        // RemoteConfig.shared.needLogs = apikeys.contains(apiKey)
        RemoteConfig.shared.needLogs = true
    }
    
    private func checkVersion(version: String) {
        let currentVesion = Bundle.sdkVersion
        if version != currentVesion {
            SBLogger.log(level: .merchant, .MerchantAlert.alertVersion)
        }
    }
}
