//
//  HelperConfigManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 06.12.2023.
//

import Foundation

final class HelperConfigManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(HelperConfigManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: HelperConfigManager = DefaultHelperConfigManager(featureToggle: container.resolve())
            return service
        }
    }
}

protocol HelperConfigManager {
    
    var config: SBHelperConfig { get }
    var helpersNeeded: Bool { get }
    func setConfig(_ config: SBHelperConfig)
    func setHelpersNeeded(_ value: Bool)
    func helperAvaliable(bannerListType: BannerListType) -> Bool
}

final class DefaultHelperConfigManager: HelperConfigManager {
    
    var config = SBHelperConfig()
    
    private let featureToggle: FeatureToggleService
    
    var helpersNeeded = true
    
    func setConfig(_ config: SBHelperConfig) {
        self.config = config
        checkHelpers()
    }
    
    init(featureToggle: FeatureToggleService) {
        self.featureToggle = featureToggle
    }
    
    func setHelpersNeeded(_ value: Bool) {
        self.helpersNeeded = value
        checkHelpers()
    }
    
    private func checkHelpers() {
        
        if !config.creditCard && !config.debitCard && !config.sbp {
            helpersNeeded = false
        }
    }
    
    func helperAvaliable(bannerListType: BannerListType) -> Bool {
        
        switch bannerListType {
        case .sbp:
            return config.sbp && featureToggle.isEnabled(.sbp)
        case .creditCard:
            return config.creditCard && featureToggle.isEnabled(.newCreditCard)
        case .debitCard:
            return config.debitCard && featureToggle.isEnabled(.newDebitCard)
        case .unknown:
            return false
        }
    }
}
