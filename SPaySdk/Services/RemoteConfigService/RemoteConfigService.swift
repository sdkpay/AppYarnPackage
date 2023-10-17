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
    func getConfig(with apiKey: String?, completion: @escaping (SDKError?) -> Void)
}

final class DefaultRemoteConfigService: RemoteConfigService {
    private let network: NetworkService
    private let optimizationManager = OptimizationCheсkerManager()
    private var apiKey: String?
    private let featureToggle: FeatureToggleService
    private let analytics: AnalyticsService
    private var retryWithCerts = true
    
    init(network: NetworkService,
         analytics: AnalyticsService,
         featureToggle: FeatureToggleService) {
        self.network = network
        self.analytics = analytics
        self.featureToggle = featureToggle
    }
    
    func getConfig(with apiKey: String?,
                   completion: @escaping (SDKError?) -> Void) {
        self.apiKey = apiKey
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
                self.analytics.sendEvent(.RQGoodRemoteConfig,
                                         with: [AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue])
                completion(nil)
            case .failure(let error):
                self.sendAnaliticsError(error: error)
                completion(error)
            }
        }
    }
    
    private func saveConfig(_ value: ConfigModel) {
        //        optimizationManager.checkSavedDataSize(object: value) {
        //            self.analytics.sendEvent(.DataSize, with: [$0])
        //        }
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
    
    private func sendAnaliticsError(error: SDKError) {
        switch error {
            
        case .noInternetConnection:
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .noData:
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .badResponseWithStatus(let code):
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: code.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .failDecode(let text):
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: Int64(200),
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
            self.analytics.sendEvent(
                .RSFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.ParsingError: text
                    ]
            )
        case .badDataFromSBOL(let httpCode):
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: [
                    AnalyticsKey.httpCode: httpCode
                ]
            )
        case .unauthorizedClient(let httpCode):
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .personalInfo:
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case let .errorWithErrorCode(number, httpCode):
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.errorCode: number,
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .noCards:
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .cancelled:
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .timeOut(let httpCode):
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .ssl(let httpCode):
            self.analytics.sendEvent(
                .RQFailRemoteConfig,
                with: 
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue
                    ]
            )
        case .bankAppNotFound:
            return
        }
    }
}
