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
    
    private var routeMaps: [Assembly] = [
        
        SDKRouteMapAssembly(),
        AuthRouteMapAssembly(),
        ChallengeRouteMapAssembly(),
        PaymentRouteMapAssembly()
    ]
    
    func registerServices(to locator: LocatorService) {
        
        for assembly in startAssemblies
                + sessionAssemblies
                + routeMaps {
            assembly.register(in: locator)
        }
    }
    
    func removeSessionServices(from locator: LocatorService) {
        
        for assembly in sessionAssemblies {
            locator.remove(assembly.type)
        }
    }
}
