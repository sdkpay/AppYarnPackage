//
//  BiometricType.swift
//  SPaySdk
//
//  Created by Арсений on 15.08.2023.
//

import LocalAuthentication

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
