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
                                                                      analytics: container.resolve(),
                                                                      featureToggle: container.resolve())
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
    private let featureToggle: FeatureToggleService
    private let analytics: AnalyticsService

    init(network: NetworkService,
         analytics: AnalyticsService,
         featureToggle: FeatureToggleService) {
        self.network = network
        self.analytics = analytics
        self.featureToggle = featureToggle
    }
    
    func getConfig(with apiKey: String, completion: @escaping (SDKError?) -> Void) {
        self.apiKey = apiKey
        network.request(ConfigTarget.getConfig,
                        to: ConfigModel.self,
                        retrySettings: (5, [])) { [weak self] result in
            switch result {
            case .success(let config):
                self?.saveConfig(config)
                self?.checkWhiteLogList(apikeys: config.apikey)
                self?.checkVersion(version: config.version)
                self?.setFeatures(config.featuresToggle)
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
        UserDefaults.bankApps = value.bankApps
        UserDefaults.images = value.images
    }
    
    private func setFeatures(_ values: [FeaturesToggle]) {
        featureToggle.setFeatures(values)
    }
    
    private func checkWhiteLogList(apikeys: [String]) {
    }
    
    private func checkVersion(version: String) {
        let currentVesion = Bundle.sdkVersion
        if version != currentVesion {
            SBLogger.log(level: .merchant, Strings.Merchant.Alert.version)
        }
    }
}
