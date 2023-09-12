//
//  AssemblieManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 28.04.2023.
//

import Foundation

final class AssemblyManager {
    private var assemblies: [Assembly] = [
        KeychainStorageAssembly(),
        AuthManagerAssembly(),
        CookieStorageAssembly(),
        BiometricAuthProviderAssembly(),
        EnvironmentManagerAssembly(),
        HostManagerAssembly(),
        FeatureToggleServiceAssembly(),
        AnalyticsServiceAssembly(),
        PersonalMetricsServiceAssembly(),
        BankAppManagerAssembly(),
        BaseRequestManagerAssembly(),
        NetworkServiceAssembly(),
        RemoteConfigServiceAssembly(),
        AlertServiceAssembly(),
        SDKManagerAssembly(),
        AuthServiceAssembly(),
        OTPManagerAssembly(),
        KeyboardManagerAssembly(),
        OTPServiceAssembly(),
        UserServiceAssembly(),
        LocationManagerAssembly(),
        PaymentServiceAssembly(),
        PartPayServiceAssembly(),
        ContentLoadManagerAssembly()
    ]
    
    func registerServices(to locator: LocatorService) {
        for assembly in assemblies {
            assembly.register(in: locator)
        }
    }
}
