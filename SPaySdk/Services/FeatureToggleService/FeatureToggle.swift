//
//  FeatureToggle.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 28.04.2023.
//

import Foundation

enum Feature {
    case bnpl
}

struct FeatureModel {
    let feature: Feature
    var isEnabled: Bool
}

final class FeatureToggleServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: FeatureToggleService = DefaultFeatureToggleService()
        container.register(service: service)
    }
}

protocol FeatureToggleService {
    func isEnabled(_ feature: Feature) -> Bool
    func setFeature(_ feature: FeatureModel)
    func setFeatureStatus(_ feature: Feature, with value: Bool)
}

final class DefaultFeatureToggleService: FeatureToggleService {
    private var features: [FeatureModel] = []
    
    func setFeature(_ feature: FeatureModel) {
        features.append(feature)
    }
    
    func isEnabled(_ feature: Feature) -> Bool {
        features.first(where: { $0.feature == feature })?.isEnabled ?? false
    }
    
    func setFeatureStatus(_ feature: Feature, with value: Bool) {
        if var feature = features.first(where: { $0.feature == feature }) {
            feature.isEnabled = value
        } else {
            let feature = FeatureModel(feature: feature, isEnabled: value)
            features.append(feature)
        }
    }
}
