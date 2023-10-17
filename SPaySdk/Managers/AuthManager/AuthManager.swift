//
//  AuthManager.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

enum AuthMethod {
    case refresh
    case bank
}

final class AuthManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: AuthManager = DefaultAuthManager()
            return service
        }
    }
}

protocol AuthManager {
    var orderNumber: String? { get set }
    var apiKey: String? { get set }
    var sessionId: String? { get set }
    var authCode: String? { get set }
    var state: String? { get set }
    var lang: String? { get set }
    var userInfo: UserInfoModel? { get set }
    var authMethod: AuthMethod? { get set }
    var ipAddress: String? { get set }
}

final class DefaultAuthManager: AuthManager {
    var orderNumber: String?
    var apiKey: String?
    var sessionId: String?
    var authCode: String?
    var state: String?
    var lang: String?
    var ipAddress: String?
    var userInfo: UserInfoModel?
    var authMethod: AuthMethod?
}
