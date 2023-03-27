//
//  AuthTarget.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

enum AuthTarget {
    case getSessionId(redirectUri: String,
                      merchantLogin: String?,
                      orderId: String?,
                      amount: Int?,
                      currency: String?,
                      orderNumber: String?,
                      expiry: String?,
                      frequency: Int?)
    case checkSession(sessionId: String)
}

extension AuthTarget: TargetType {
    var path: String {
        switch self {
        case .getSessionId:
            return "/sessionId"
        case .checkSession:
            return "/sessionStatus"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSessionId:
            return .post
        case .checkSession:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            
        case let .getSessionId(redirectUri: redirectUri,
                               merchantLogin: merchantLogin,
                               orderId: orderId,
                               amount: amount,
                               currency: currency,
                               orderNumber: orderNumber,
                               expiry: expiry,
                               frequency: frequency):
            var params: [String: Any] = [
                "redirectUri": redirectUri
            ]
            
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            if let orderId = orderId {
                params["orderId"] = orderId
            }
            if let amount = amount,
               amount != 0,
               let currency = currency,
               let orderNumber = orderNumber {
                var purchaceParams: [String: Any] = [
                    "amount": amount,
                    "currency": currency,
                    "orderNumber": orderNumber
                ]
                
                if let expiry = expiry,
                    let frequency = frequency,
                   frequency != 0 {
                    let recurrent: [String: Any] = [
                        "enabled": true,
                        "expiry": expiry,
                        "frequency": frequency
                    ]
                    
                    purchaceParams["recurrent"] = recurrent
                }
                
                params["purchase"] = purchaceParams
            }
            
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
        case .getSessionId:
            return StubbedResponse.auth.data
        case .checkSession:
            return nil
        }
    }
}
