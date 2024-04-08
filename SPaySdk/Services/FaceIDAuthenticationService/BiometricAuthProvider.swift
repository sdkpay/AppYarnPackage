//
//  BiometricAuthProvider.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023
//

import Foundation
import LocalAuthentication

final class BiometricAuthProviderAssembly: Assembly {
    
    var type = ObjectIdentifier(BiometricAuthProviderProtocol.self)
    
    func register(in container: LocatorService) {
        let service: BiometricAuthProviderProtocol = BiometricAuthProvider()
        container.register(service: service)
    }
}

protocol BiometricAuthProviderProtocol: AuthenticationEvaluateProtocol {
    func evaluate() async -> Bool
    func canEvalute() async -> Bool
    init(context: DefaultAuthenticationContext)
}

final class BiometricAuthProvider: BiometricAuthProviderProtocol {

    // MARK: - Properties
    private let context: DefaultAuthenticationContext

    // MARK: - Initialization
    required init(context: DefaultAuthenticationContext = DefaultAuthenticationContext() ) {
        self.context = context
    }
    
    @MainActor
    func canEvalute() async -> Bool {
        
        do {
            return await withCheckedContinuation({( inCont: CheckedContinuation<Bool, Never>) -> Void in
                self.context.canEvaluate(completion: { result, _, _ in
                    inCont.resume(with: .success(result))
                })
            })
        }
    }

    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void) {
        self.context.canEvaluate(completion: completion)
    }
    
    @MainActor
    func evaluate() async -> Bool {
        
        self.context.reset()
        
        do {
            return await withCheckedContinuation({( inCont: CheckedContinuation<Bool, Never>) -> Void in
                self.context.evaluate { result, _ in
                    
                    inCont.resume(with: .success(result))
                }
            })
        }
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
