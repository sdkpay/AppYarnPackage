//
//  AuthModel.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

struct AuthModel: Codable {
    let deeplink: String
    let state: String
    let sessionId: String
    let clientId: String
    let nonce: String
    let isBnplEnabled: Bool?
    let codeChallengeMethod: String
    let codeChallenge: String
    let score: String
    let refreshTokenlsActive: Bool?
}

struct AuthRefreshModel {
    let sessionId: String
    let userInfo: UserInfo
    let merchantName: String?
    let logo: String?
    
    struct UserInfo {
        let lastName: String
        let firstName: String
        let gender: Int?
        let mobilePhone: String?
    }
}


