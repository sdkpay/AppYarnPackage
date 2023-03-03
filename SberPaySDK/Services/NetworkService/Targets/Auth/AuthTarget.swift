//
//  AuthTarget.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

enum AuthTarget {
    case getSessionIdByDefault(redirectUri: String,
                      merchantLogin: String?,
                      orderId: String)
    
    case getSessionIdByPurchase(redirectUri: String,
                                merchantLogin: String?,
                                amount: Int,
                                currency: String,
                                orderNumber: String)
}

extension AuthTarget: TargetType {
    var path: String {
        switch self {
        case .getSessionIdByDefault, .getSessionIdByPurchase:
            return "/sessionId"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSessionIdByDefault, .getSessionIdByPurchase:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        
        case let .getSessionIdByPurchase(redirectUri: redirectUri,
                                         merchantLogin: merchantLogin,
                                         amount: amount,
                                         currency: currency,
                                         orderNumber: orderNumber):
            var params = getParameters(redirectUri: redirectUri, merchantLogin: merchantLogin)
            
            let purchaceParams: [String: Any] = [
                "amount": amount,
                "currency": currency,
                "orderNumber": orderNumber
            ]
            params["purchase"] = purchaceParams
            
            return .requestWithParameters(nil, bodyParameters: params)
        case let .getSessionIdByDefault(redirectUri: redirectUri,
                               merchantLogin: merchantLogin,
                               orderId: orderId):

            var params = getParameters(redirectUri: redirectUri, merchantLogin: merchantLogin)
            params["orderId"] = orderId
            

            return .requestWithParameters(nil, bodyParameters: params)
        }
    }
    
    private func getParameters(redirectUri: String,
                               merchantLogin: String?) -> [String: Any] {
        
        var params: [String: Any] = [
            "redirectUri": redirectUri
        ]
        if let merchantLogin = merchantLogin {
            params["merchantLogin"] = merchantLogin
        }
        
        return params
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getSessionIdByDefault, .getSessionIdByPurchase:
            return StubbedResponse.auth.data
        }
    }
}
 
