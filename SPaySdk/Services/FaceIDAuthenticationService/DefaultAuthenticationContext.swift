//
//  DefaultAuthenticationContext.swift
//  SPaySdk
//
//  Created by Арсений on 16.08.2023.
//

import LocalAuthentication

protocol AuthenticationContextProtocol: AuthenticationEvaluateProtocol {
    init()
    func reset()
}

protocol AuthenticationEvaluateProtocol {
    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void)
    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void)
    var canEvaluatePolicy: Bool { get }
    var biometricType: BiometricType { get }
}

final class DefaultAuthenticationContext: AuthenticationContextProtocol {

    // MARK: - Properties
    private var context: LAContext
    private let policy: LAPolicy
    private var error: NSError?

    // MARK: - Initialization
    init() {
        context = LAContext()
        policy = .deviceOwnerAuthenticationWithBiometrics
    }

    init(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics) {
        context = LAContext()
        self.policy = policy
    }

    func reset() {
        context = LAContext()
    }

    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void) {
        guard context.canEvaluatePolicy(policy, error: &error) else {
            let type = BiometricType(type: context.biometryType)

            guard let error = error else {
                return completion(false, type, nil)
            }

            return completion(false, type, BiometricError(error: error))
        }

        completion(true, BiometricType(type: context.biometryType), nil)
    }

    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void) {
        context.evaluatePolicy(
            policy,
            localizedReason: ""
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    guard let error = error else { return completion(false, nil) }

                    completion(false, BiometricError(error: error as NSError))
                }
            }
        }
    }

    var canEvaluatePolicy: Bool {
        context.canEvaluatePolicy(policy, error: nil)
    }

    var biometricType: BiometricType {
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .unknown
        }
    }
}
