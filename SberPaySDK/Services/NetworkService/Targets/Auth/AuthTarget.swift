//
//  AuthTarget.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

enum AuthTarget {
    case getSessionId(redirectUri: String, merchantLogin: String?, orderId: String?)
}

extension AuthTarget: TargetType {
    var path: String {
        switch self {
        case .getSessionId:
            return "/sessionId"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSessionId:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case let .getSessionId(redirectUri: redirectUri, merchantLogin: merchantLogin, orderId: orderId):
            var params = [
                "redirectUri": redirectUri
            ]
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            if let orderId = orderId {
                params["orderId"] = orderId
            }
            return .requestWithParameters(nil, bodyParameters: params)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getSessionId:
            return StubbedResponse.auth.data
        }
    }
}
 
