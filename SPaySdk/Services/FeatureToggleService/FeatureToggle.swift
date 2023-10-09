//
//  FeatureToggle.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 28.04.2023.
//

import Foundation

enum Feature: String, Codable {
    case bnpl
    case refresh
    case bnpl2
}

final class FeatureToggleServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: FeatureToggleService = DefaultFeatureToggleService()
        container.register(service: service)
    }
}

protocol FeatureToggleService {
    func isEnabled(_ feature: Feature) -> Bool
    func setFeature(_ feature: FeaturesToggle)
    func setFeatures(_ features: [FeaturesToggle])
}

final class DefaultFeatureToggleService: FeatureToggleService {
    private var features: [FeaturesToggle] = []
    
    func setFeature(_ feature: FeaturesToggle) {
        features.append(feature)
    }
    
    func setFeatures(_ features: [FeaturesToggle]) {
        self.features.append(contentsOf: features)
    }
    
    func isEnabled(_ feature: Feature) -> Bool {
        getFeature(feature)?.value ?? false
    }
    
    private func getFeature(_ feature: Feature) -> FeaturesToggle? {
        features.first(where: { $0.name == feature.rawValue })
    }
}
