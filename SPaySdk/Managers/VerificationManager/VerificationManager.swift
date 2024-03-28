//
//  VerificationManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.03.2024.
//

import UIKit

extension MetricsValue {
    
    static let bioAuth = MetricsValue(rawValue: "BioAuth")
}

final class VerificationManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(VerificationManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: VerificationManager = DefaultVerificationManager(authService: container.resolve(),
                                                                          biometricAuthProvider: container.resolve(),
                                                                          analytics: container.resolve(),
                                                                          authManager: container.resolve())
            return service
        }
    }
}

protocol VerificationManager {
    @MainActor
    func verify() async throws
}

final class DefaultVerificationManager: VerificationManager {

    private let authService: AuthService
    private let authManager: AuthManager
    private let analytics: AnalyticsManager
    private let biometricAuthProvider: BiometricAuthProvider
    
    init(authService: AuthService,
         biometricAuthProvider: BiometricAuthProvider,
         analytics: AnalyticsManager,
         authManager: AuthManager) {
        self.authService = authService
        self.biometricAuthProvider = biometricAuthProvider
        self.authManager = authManager
        self.analytics = analytics
    }
    
    @MainActor
    func verify() async throws {
        
        switch authManager.authMethod {
            
        case .bank, .sid:
            return
        case .refresh:
            
            let canEvalute = await biometricAuthProvider.canEvalute()
            
            switch canEvalute {
            case true:
                let result = await biometricAuthProvider.evaluate()
                
                switch result {
                case true:
                    analytics.send(EventBuilder()
                        .with(base: .LC)
                        .with(state: .Good)
                        .with(value: .bioAuth)
                        .build())
                    
                    return
                case false:
                    try await authService.appAuth()
                    try await authService.auth()
                    return
                }
            case false:
                analytics.send(EventBuilder()
                    .with(base: .LC)
                    .with(state: .Fail)
                    .with(value: .bioAuth)
                    .build())
                throw SDKError(.noData)
            }
            
        case .none:
            throw SDKError(.noData)
        }
    }
}

