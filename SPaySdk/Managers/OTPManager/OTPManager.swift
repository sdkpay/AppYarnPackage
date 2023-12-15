//
//  OTPManager.swift
//  SPaySdk
//
//  Created by Арсений on 08.08.2023.
//

import Foundation

final class OTPManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(OTPManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: OTPManager = DefaultAOTPManager()
            return service
        }
    }
}

protocol OTPManager {
    var apiKey: String? { get set }
    var sessionId: String? { get set }
    var authCode: String? { get set }
    var state: String? { get set }
    var lang: String? { get set }
}

final class DefaultAOTPManager: OTPManager {
    var apiKey: String?
    var sessionId: String?
    var authCode: String?
    var state: String?
    var lang: String?
}
