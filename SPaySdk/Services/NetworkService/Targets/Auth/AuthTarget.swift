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
                      frequency: Int?,
                      headers: HTTPHeaders?)
    case checkSession(sessionId: String)
    case auth(redirectUri: String?,
              authCode: String?,
              sessionId: String,
              state: String?,
              deviceInfo: String?,
              orderId: String?,
              amount: Int,
              currency: Int,
              mobilePhone: String?,
              orderNumber: String,
              description: String?,
              enabled: Bool,
              expiry: String?,
              frequency: Int?,
              userName: String?,
              merchantLogin: String?,
              headers: HTTPHeaders?
    )
}

extension AuthTarget: TargetType {
    var path: String {
        switch self {
        case .getSessionId:
            return "/sessionId"
        case .checkSession:
            return "/sessionStatus"
        case .auth:
            return "/sdkAuth"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSessionId:
            return .post
        case .checkSession:
            return .get
        case .auth:
            return .post
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
                               frequency: frequency,
                               headers: headers):
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
            
            return .requestWithParametersAndHeaders(nil, bodyParameters: params, headers: headers)
        case .checkSession(sessionId: let sessionId):
            let params = [
                "sessionId": sessionId
            ]
            return .requestWithParametersAndHeaders(params, headers: headers)
        case .auth(redirectUri: let redirectUri,
                   authCode: let authCode,
                   sessionId: let sessionId,
                   state: let state,
                   deviceInfo: let deviceInfo,
                   orderId: let orderId,
                   amount: let amount,
                   currency: let currency,
                   mobilePhone: let mobilePhone,
                   orderNumber: let orderNumber,
                   description: let description,
                   enabled: let enabled,
                   expiry: let expiry,
                   frequency: let frequency,
                   userName: let userName,
                   merchantLogin: let merchantLogin,
                   headers: let headers):
            
            var params: [String: Any] = [:]

            if let redirectUri {
                params["redirectUri"] = redirectUri
            }
            
            if let authCode {
                params["authCode"] = authCode
            }
            
            params["sessionId"] = sessionId
            
            if let state {
                params["state"] = state
            }
            
            if let orderId = orderId {
                params["orderId"] = orderId
            }
            
            if let deviceInfo {
                params["deviceInfo"] = deviceInfo
            }
            if amount != 0 {
                var purchaceParams: [String: Any] = [
                    "amount": amount,
                    "currency": currency,
                    "orderNumber": orderNumber
                ]
                
                if let description {
                    purchaceParams["description"] = description
                }
                
                if let mobilePhone {
                    purchaceParams["mobilePhone"] = mobilePhone
                }
                
                if let expiry, let frequency {
                    var recurrent: [String: Any] = [
                        "enabled": enabled,
                        "expiry": expiry,
                        "frequency": frequency
                    ]
                    
                    purchaceParams["recurrent"] = recurrent
                }
                params["purchase"] = purchaceParams
            }
            
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            
            if let userName = userName {
                params["userName"] = userName
            }
            
            return .requestWithParametersAndHeaders(params, headers: headers)
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
        case .auth:
            return nil
        }
    }
}
