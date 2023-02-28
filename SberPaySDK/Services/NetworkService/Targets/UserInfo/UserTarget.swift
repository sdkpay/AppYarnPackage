//
//  UserTarget.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum UserTarget {
    case getListCards(redirectUri: String,
                      authCode: String,
                      sessionId: String,
                      state: String,
                      merchantLogin: String?,
                      orderId: String?)
    case checkSession(sessionId: String)
}

extension UserTarget: TargetType {
    var path: String {
        switch self {
        case .getListCards:
            return "/listCards"
        case .checkSession:
            // DEBUG
            return "/sessionId"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getListCards:
            return .post
        case .checkSession:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case let .getListCards(redirectUri: redirectUri,
                               authCode: authCode,
                               sessionId: sessionId,
                               state: state,
                               merchantLogin: merchantLogin,
                               orderId: orderId):
            var params = [
                "redirectUri": redirectUri,
                "authCode": authCode,
                "sessionId": sessionId,
                "state": state
            ]
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            if let orderId = orderId {
                params["orderId"] = orderId
            }
            return .requestWithParametersAndHeaders(nil, bodyParameters: params)
        case .checkSession(sessionId: let sessionId):
            let params = [
                "sessionId": sessionId
            ]
            return .requestWithParameters(params)
        }
    }

    var headers: HTTPHeaders? {
        return nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getListCards:
            return StubbedResponse.listCards.data
        case .checkSession:
            return StubbedResponse.validSession.data
        }
    }
}
