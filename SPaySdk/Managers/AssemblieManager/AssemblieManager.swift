//
//  AssemblieManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 28.04.2023.
//

import Foundation

final class AssemblyManager {
    
    private var startAssemblies: [Assembly] = [
        
        HelperConfigManagerAssembly(),
        VersionСontrolManagerAssembly(),
        AuthManagerAssembly(),
        PaymentServiceAssembly(),
        CompletionManagerAssembly(),
        SDKManagerAssembly(),
        CookieStorageAssembly(),
        EnvironmentManagerAssembly(),
        HostManagerAssembly(),
        AnalyticsServiceAssembly(),
        BankAppManagerAssembly(),
        ParsingErrorAnaliticManagerAssembly(),
        FeatureToggleServiceAssembly(),
        BaseRequestManagerAssembly(),
        NetworkServiceAssembly(),
        RemoteConfigServiceAssembly()
    ]
    
    private var sessionAssemblies: [Assembly] = [
        
        BiometricAuthProviderAssembly(),
        KeychainStorageAssembly(),
        PaymentServiceAssembly(),
        PersonalMetricsServiceAssembly(),
        AlertServiceAssembly(),
        SeamlessAuthServiceAssembly(),
        AuthServiceAssembly(),
        OTPManagerAssembly(),
        OTPServiceAssembly(),
        UserServiceAssembly(),
        LocationManagerAssembly(),
        SecureChallengeServiceAssembly(),
        PartPayServiceAssembly(),
        PayAmountValidationManagerAssembly(),
        ContentLoadManagerAssembly()
    ]
    
    func registerStartServices(to locator: LocatorService) {
        
        for assembly in startAssemblies {
            assembly.register(in: locator)
        }
    }
    
    func registerSessionServices(to locator: LocatorService) {
        
        for assembly in sessionAssemblies {
            assembly.register(in: locator)
        }
    }
}
