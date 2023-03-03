//
//  UserTarget.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum UserTarget {
    case getListCardsByDefault(redirectUri: String,
                               authCode: String,
                               sessionId: String,
                               state: String,
                               merchantLogin: String?,
                               orderId: String)
    
    case getListCardsByPachase(redirectUri: String,
                               authCode: String,
                               sessionId: String,
                               state: String,
                               merchantLogin: String?,
                               amount: Int,
                               currency: String,
                               orderNumber: String)
    case checkSession(sessionId: String)
}

extension UserTarget: TargetType {
    var path: String {
        switch self {
        case .getListCardsByDefault, .getListCardsByPachase:
            return "/listCards"
        case .checkSession:
            // DEBUG
            return "/sessionId"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getListCardsByDefault, .getListCardsByPachase:
            return .post
        case .checkSession:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            
        case let .getListCardsByPachase(redirectUri: redirectUri,
                                        authCode: authCode,
                                        sessionId: sessionId,
                                        state: state,
                                        merchantLogin: merchantLogin,
                                        amount: amount,
                                        currency: currency,
                                        orderNumber: orderNumber):
            
            var params = getParameters(redirectUri: redirectUri,
                                       authCode: authCode,
                                       sessionId: sessionId,
                                       state: state,
                                       merchantLogin: merchantLogin)
            
            let purchaceParams: [String: Any] = [
                "amount": amount,
                "currency": currency,
                "orderNumber": orderNumber
            ]
            params["purchase"] = purchaceParams
            
            return .requestWithParametersAndHeaders(nil, bodyParameters: params)
        case let .getListCardsByDefault(redirectUri: redirectUri,
                                        authCode: authCode,
                                        sessionId: sessionId,
                                        state: state,
                                        merchantLogin: merchantLogin,
                                        orderId: orderId):
            
            var params = getParameters(redirectUri: redirectUri,
                                       authCode: authCode,
                                       sessionId: sessionId,
                                       state: state,
                                       merchantLogin: merchantLogin)
            
            params["orderId"] = orderId
            
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
        case .getListCardsByDefault, .getListCardsByPachase:
            return StubbedResponse.listCards.data
        case .checkSession:
            return StubbedResponse.validSession.data
        }
    }
    
    private func getParameters(redirectUri: String,
                               authCode: String,
                               sessionId: String,
                               state: String,
                               merchantLogin: String?) -> [String: Any] {
        var params: [String: Any] = [
            "redirectUri": redirectUri,
            "authCode": authCode,
            "sessionId": sessionId,
            "state": state
        ]
        
        if let merchantLogin = merchantLogin {
            params["merchantLogin"] = merchantLogin
        }
        
        return params
    }
}
