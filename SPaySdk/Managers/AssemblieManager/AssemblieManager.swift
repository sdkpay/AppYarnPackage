//
//  AssemblieManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 28.04.2023.
//

import Foundation

final class AssemblyManager {
    private var assemblies: [Assembly] = [
        VersionСontrolManagerAssembly(),
        KeychainStorageAssembly(),
        AuthManagerAssembly(),
        PaymentServiceAssembly(),
        CompletionManagerAssembly(),
        SDKManagerAssembly(),
        CookieStorageAssembly(),
        BiometricAuthProviderAssembly(),
        EnvironmentManagerAssembly(),
        HostManagerAssembly(),
        FeatureToggleServiceAssembly(),
        AnalyticsServiceAssembly(),
        ParsingErrorAnaliticManagerAssembly(),
        BankAppManagerAssembly(),
        BaseRequestManagerAssembly(),
        NetworkServiceAssembly(),
        PersonalMetricsServiceAssembly(),
        RemoteConfigServiceAssembly(),
        SDKManagerAssembly(),
        AlertServiceAssembly(),
        AuthServiceAssembly(),
        OTPManagerAssembly(),
        KeyboardManagerAssembly(),
        OTPServiceAssembly(),
        UserServiceAssembly(),
        LocationManagerAssembly(),
        SecureChallengeServiceAssembly(),
        PartPayServiceAssembly(),
        ContentLoadManagerAssembly()
    ]
    
    func registerServices(to locator: LocatorService) {
        for assembly in assemblies {
            assembly.register(in: locator)
        }
    }
}
