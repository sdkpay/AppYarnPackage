//
//  UserTarget.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum UserTarget {
    case getListCards(redirectUri: String,
                      apiKey: String,
                      authCode: String,
                      sessionId: String,
                      state: String,
                      merchantLogin: String,
                      orderId: String)
    case checkSession(sessionId: String)
}

extension UserTarget: TargetType {
    var path: String {
        switch self {
        case .getListCards:
            return "sdk-gateway/v1/listCards"
        case .checkSession:
            // DEBUG
            return "sdk-gateway/v1/sessionId"
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
                               apiKey: apiKey,
                               authCode: authCode,
                               sessionId: sessionId,
                               state: state,
                               merchantLogin: merchantLogin,
                               orderId: orderId):
            let params = [
                "redirectUri": redirectUri,
                "apiKey": apiKey,
                "authCode": authCode,
                "sessionId": sessionId,
                "state": state,
                "merchantLogin": merchantLogin,
                "orderId": orderId
            ]
            return .requestWithParameters(nil, bodyParameters: params)
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
