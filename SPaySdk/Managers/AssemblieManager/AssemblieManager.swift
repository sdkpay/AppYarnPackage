//
//  AssemblieManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 28.04.2023.
//

import Foundation

final class AssemblyManager {
    
    private var startAssemblies: [Assembly] = [
        
        SetupManagerAssembly(),
        KeychainStorageAssembly(),
        VersionСontrolManagerAssembly(),
        AuthManagerAssembly(),
        AnalyticsServiceAssembly(),
        PaymentServiceAssembly(),
        CompletionManagerAssembly(),
        SDKManagerAssembly(),
        AnalyticsServiceManager(),
        CookieStorageAssembly(),
        EnvironmentManagerAssembly(),
        HostManagerAssembly(),
        BankAppManagerAssembly(),
        FeatureToggleServiceAssembly(),
        HelperConfigManagerAssembly(),
        BaseRequestManagerAssembly(),
        NetworkServiceAssembly(),
        RemoteConfigServiceAssembly()
    ]
    
    private var sessionAssemblies: [Assembly] = [
        
        BiometricAuthProviderAssembly(),
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
        PayAmountValidationManagerAssembly()
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
    
    func removeSessionServices(from locator: LocatorService) {
        
        for assembly in sessionAssemblies {
            locator.remove(assembly.type)
        }
    }
}
