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
                                                                      featureToggle: container.resolve(),
                                                                      sdkManager: container.resolve())
        container.register(service: service)
    }
}

protocol RemoteConfigService {
    func getConfig(with apiKey: String, completion: @escaping (SDKError?) -> Void)
}

final class DefaultRemoteConfigService: RemoteConfigService {
    private let network: NetworkService
    private let sdkManager: SDKManager
    private let optimizationManager = OptimizationCheсkerManager()
    private var apiKey: String?
    private let featureToggle: FeatureToggleService
    private let analytics: AnalyticsService
    private var retryWithCerts = true

    init(network: NetworkService,
         analytics: AnalyticsService,
         featureToggle: FeatureToggleService,
         sdkManager: SDKManager) {
        self.network = network
        self.analytics = analytics
        self.featureToggle = featureToggle
        self.sdkManager = sdkManager
    }
    
    func getConfig(with apiKey: String,
                   completion: @escaping (SDKError?) -> Void) {
        self.apiKey = apiKey
        analytics.sendEvent(.RQRemoteConfig)
        network.request(ConfigTarget.getConfig,
                        to: ConfigModel.self,
                        retrySettings: (2, [])) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let config):
                self.saveConfig(config)
                self.checkWhiteLogList(apikeys: config.apikey)
                self.checkVersion(version: config.version)
                self.setFeatures(config.featuresToggle)
                analytics.sendEvent(.RQGoodRemoteConfig)
                completion(nil)
            case .failure(let error):
                let target: AnalyticsEvent = error.represents(.failDecode) ? .RQFailRemoteConfig : .RQFailRemoteConfig
                analytics.sendEvent(target, with: "error: \(error.localizedDescription)")
                completion(error)
            }
        }
    }
    
    private func saveConfig(_ value: ConfigModel) {
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
