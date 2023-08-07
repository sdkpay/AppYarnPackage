//
//  BiometricAuthProvider.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023
//

import Foundation
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
    private let localizedReason: String
    private var error: NSError?

    // MARK: - Initialization
    init() {
        context = LAContext()
        context.localizedFallbackTitle = "Enter App Password"
        context.localizedCancelTitle = "Cancel"
        policy = .deviceOwnerAuthenticationWithBiometrics
        localizedReason = "Verify your Identity"
    }

    init(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
         localizedReason: String,
         localizedFallbackTitle: String,
         cancelTitle: String) {
        context = LAContext()
        context.localizedFallbackTitle = localizedFallbackTitle
        context.localizedCancelTitle = cancelTitle
        self.policy = policy
        self.localizedReason = localizedReason
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
            localizedReason: localizedReason
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

// MARK: - Biometric Type
enum BiometricType {
    case none, touchID, faceID, unknown

    init(type: LABiometryType) {
        switch type {
        case .none:
            self = .none
        case .touchID:
            self = .touchID
        case .faceID:
            self = .faceID
        @unknown default:
            self = .unknown
        }
    }
}

// MARK: - Biometric Error
enum BiometricError: LocalizedError {
    case authenticationFailed
    case userCancel
    case userFallback
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown

    init(error: NSError) {
        switch error {
        case LAError.authenticationFailed:
            self = .authenticationFailed
        case LAError.userCancel:
            self = .userCancel
        case LAError.userFallback:
            self = .userFallback
        case LAError.biometryNotAvailable:
            self = .biometryNotAvailable
        case LAError.biometryNotEnrolled:
            self = .biometryNotEnrolled
        case LAError.biometryLockout:
            self = .biometryLockout
        default:
            self = .unknown
        }
    }

    var errorDescription: String? {
        switch self {
        case .authenticationFailed: return "There was a problem verifying your identity."
        case .userCancel: return "You pressed cancel."
        case .userFallback: return "You pressed password."
        case .biometryNotAvailable: return "Face ID/Touch ID is not available."
        case .biometryNotEnrolled: return "Face ID/Touch ID is not set up."
        case .biometryLockout: return "Face ID/Touch ID is locked."
        case .unknown: return "Face ID/Touch ID may not be configured"
        }
    }
}
