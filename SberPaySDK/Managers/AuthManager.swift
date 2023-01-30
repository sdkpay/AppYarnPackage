//
//  AuthManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

protocol AuthManager {
    var sessionId: String? { get set }
    var authCode: String? { get set }
    var state: String? { get set }
}

final class DefaultAuthManager: AuthManager {
    var sessionId: String?
    var authCode: String?
    var state: String?
}
