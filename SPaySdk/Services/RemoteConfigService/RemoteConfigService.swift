//
//  RemoteConfigService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.03.2023.
//

import Foundation

final class RemoteConfigServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(RemoteConfigService.self)
    
    func register(in container: LocatorService) {
        let service: RemoteConfigService = DefaultRemoteConfigService(network: container.resolve(),
                                                                      analytics: container.resolve(),
                                                                      featureToggle: container.resolve(),
                                                                      versionСontrolManager: container.resolve())
        container.register(service: service)
    }
}

protocol RemoteConfigService {
    
    func getConfig(with apiKey: String?) async throws
}

final class DefaultRemoteConfigService: RemoteConfigService {
    private let network: NetworkService
    private let optimizationManager = OptimizationCheсkerManager()
    private var apiKey: String?
    private let featureToggle: FeatureToggleService
    private let analytics: AnalyticsService
    private let versionСontrolManager: VersionСontrolManager
    private var retryWithCerts = true
    
    init(network: NetworkService,
         analytics: AnalyticsService,
         featureToggle: FeatureToggleService,
         versionСontrolManager: VersionСontrolManager) {
        self.network = network
        self.analytics = analytics
        self.versionСontrolManager = versionСontrolManager
        self.featureToggle = featureToggle
    }
    
    func getConfig(with apiKey: String?) async throws {
        
        self.apiKey = apiKey
        
        let result = try await network.request(ConfigTarget.getConfig,
                                               to: ConfigModel.self,
                                               retrySettings: (2, []))
        
        self.versionСontrolManager.setVersionsInfo(result.versionInfo)
        self.saveConfig(result)
        self.checkVersion(version: result.versionInfo?.active)
        self.setFeatures(result.featuresToggle)
    }
    
    private func saveConfig(_ value: ConfigModel) {
        UserDefaults.localization = value.localization
        UserDefaults.schemas = value.schemas
        let bankApps = value.bankApps.map({ BankApp($0, versionType: .prom) })
        let bankAppsBeta = value.bankAppsBeta?.map({ BankApp($0, versionType: .beta) }) ?? []
        UserDefaults.bankApps = bankApps + bankAppsBeta
        UserDefaults.images = value.images
        UserDefaults.certKeys = value.certHashes
    }
    
    private func setFeatures(_ values: [FeaturesToggle]) {
        featureToggle.setFeatures(values)
    }

    private func checkVersion(version: String?) {
        
        let currentVesion = Bundle.sdkVersion
        if version != currentVesion {
            SBLogger.log(level: .merchant, Strings.MerchantAlert.version)
        }
    }
}
