//
//  LocalAuthenticationService.swift
//  SPaySdk
//
//  Created by Арсений on 18.07.2023.
//

import LocalAuthentication

enum AuthenticationState {
    case loggedin, loggedout
}



protocol LocalAuthenticationServiceDelegate {
    
}

final class LocalAuthenticationService {
    var context = LAContext()
    var state = AuthenticationState.loggedout
    var code = NSError?Ў
    
    func getPermision() {
        var error: NSError?
        
        var permissions = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        if permissions {

        }
        else {
            // Handle permission denied or error
        }
    }
    
    func authenticationWithBiometrics() {
        let reason = "Log in with Face ID"
        context.evaluatePolicy(
            // .deviceOwnerAuthentication allows
            // biometric or passcode authentication
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            if success {
                // Handle successful authentication
            } else {
//                self.descriptError(code: error.co)
            }
        }
    }
    
    func descriptError(code: LAError.Code) {
        switch code {
            
        case .authenticationFailed:
            break
        case .userCancel:
            break
        case .userFallback:
            break
        case .systemCancel:
            break
        case .passcodeNotSet:
            break
        case .touchIDNotAvailable:
            break
        case .touchIDNotEnrolled:
            break
        case .touchIDLockout:
            break
        case .appCancel:
            break
        case .invalidContext:
            break
        case .notInteractive:
            break
        @unknown default:
            break
        }
    }
}
