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
}

extension UserTarget: TargetType {
    var path: String {
        switch self {
        case .getListCards:
            return "sdk-gateway/v1/listCards"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getListCards:
            return .post
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
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var sampleData: Data? {
        return StubbedResponse.listCards.data
    }
}
