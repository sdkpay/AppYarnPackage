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
    let clientId: String?
    let nonce: String?
    let isBnplEnabled: Bool?
    let codeChallengeMethod: String
    let codeChallenge: String
    let scope: String
    let refreshTokenIsActive: Bool?
}

struct AuthRefreshModel: Codable {
    let sessionId: String
    let userInfo: UserInfoModel
    let merchantName: String?
    let logo: String?
}

struct UserInfoModel: Codable {
    let lastName: String
    let firstName: String
    let gender: Int?
    let mobilePhone: String?
}
