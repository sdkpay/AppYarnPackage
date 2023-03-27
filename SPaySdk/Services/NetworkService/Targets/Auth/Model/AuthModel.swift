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
}
