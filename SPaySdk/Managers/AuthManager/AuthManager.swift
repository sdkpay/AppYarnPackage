//
//  AuthManager.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

final class AuthManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: AuthManager = DefaultAuthManager()
            return service
        }
    }
}

protocol AuthManager {
    var apiKey: String? { get set }
    var sessionId: String? { get set }
    var authCode: String? { get set }
    var state: String? { get set }
    var lang: String? { get set }
}

final class DefaultAuthManager: AuthManager {
    var apiKey: String?
    var sessionId: String?
    var authCode: String?
    var state: String?
    var lang: String?
}
