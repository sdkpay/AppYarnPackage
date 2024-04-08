//
//  BiometricError.swift
//  SPaySdk
//
//  Created by Арсений on 15.08.2023.
//

import LocalAuthentication

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
}
