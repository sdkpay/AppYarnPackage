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
                                                                      parsingErrorAnaliticManager: container.resolve(),
                                                                      versionСontrolManager: container.resolve())
        container.register(service: service)
    }
}

protocol RemoteConfigService {
    
    func getConfig(with apiKey: String?,
                   completion: @escaping (Result<Void, SDKError>) -> Void)
}

final class DefaultRemoteConfigService: RemoteConfigService {
    private let network: NetworkService
    private let optimizationManager = OptimizationCheсkerManager()
    private var apiKey: String?
    private let featureToggle: FeatureToggleService
    private let analytics: AnalyticsService
    private let parsingErrorAnaliticManager: ParsingErrorAnaliticManager
    private let versionСontrolManager: VersionСontrolManager
    private var retryWithCerts = true
    
    init(network: NetworkService,
         analytics: AnalyticsService,
         featureToggle: FeatureToggleService,
         parsingErrorAnaliticManager: ParsingErrorAnaliticManager,
         versionСontrolManager: VersionСontrolManager) {
        self.network = network
        self.analytics = analytics
        self.versionСontrolManager = versionСontrolManager
        self.featureToggle = featureToggle
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
    }
    
    func getConfig(with apiKey: String?,
                   completion: @escaping (Result<Void, SDKError>) -> Void) {
        
        self.apiKey = apiKey
        
        Task(priority: .userInitiated) {
            
            let result = await network.request(ConfigTarget.getConfig,
                                               to: ConfigModel.self,
                                               retrySettings: (2, []))
            
            switch result {
            case .success(let config):
                self.versionСontrolManager.setVersionsInfo(config.versionInfo)
                self.saveConfig(config)
                self.checkVersion(version: config.version)
                self.setFeatures(config.featuresToggle)
                self.analytics.sendEvent(.RQGoodRemoteConfig,
                                         with: [AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue])
                completion(.success)
            case .failure(let failure):
                completion(.failure(failure))
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

    private func checkVersion(version: String) {
        let currentVesion = Bundle.sdkVersion
        if version != currentVesion {
            SBLogger.log(level: .merchant, Strings.Merchant.Alert.version)
        }
    }
}
