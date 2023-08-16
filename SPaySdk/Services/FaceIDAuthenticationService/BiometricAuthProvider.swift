//
//  BiometricAuthProvider.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023
//

import Foundation
import LocalAuthentication

final class BiometricAuthProviderAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: BiometricAuthProviderProtocol = BiometricAuthProvider()
        container.register(service: service)
    }
}

protocol BiometricAuthProviderProtocol: AuthenticationEvaluateProtocol {
    init(context: DefaultAuthenticationContext)
}

final class BiometricAuthProvider: BiometricAuthProviderProtocol {

    // MARK: - Properties
    private let context: DefaultAuthenticationContext

    // MARK: - Initialization
    required init(context: DefaultAuthenticationContext = DefaultAuthenticationContext() ) {
        self.context = context
    }

    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void) {
        self.context.canEvaluate(completion: completion)
    }

    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void) {
        self.context.reset()
        self.context.evaluate(completion: completion)
    }

    var canEvaluatePolicy: Bool {
        self.context.canEvaluatePolicy
    }

    var biometricType: BiometricType {
        self.context.biometricType
    }
}
