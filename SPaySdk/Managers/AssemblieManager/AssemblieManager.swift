//
//  AssemblieManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 28.04.2023.
//

import Foundation

final class AssemblyManager {
    private var assemblies: [Assembly] = [
        EnvironmentManagerAssembly(),
        HostManagerAssembly(),
        FeatureToggleServiceAssembly(),
        AnalyticsServiceAssembly(),
        PersonalMetricsServiceAssembly(),
        BankAppManagerAssembly(),
        AuthManagerAssembly(),
        BaseRequestManagerAssembly(),
        NetworkServiceAssembly(),
        RemoteCertificateServiceAssembly(),
        RemoteConfigServiceAssembly(),
        AlertServiceAssembly(),
        SDKManagerAssembly(),
        AuthServiceAssembly(),
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
