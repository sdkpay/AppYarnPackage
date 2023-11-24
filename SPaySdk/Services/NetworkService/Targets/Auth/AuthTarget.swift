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
                      authCookie: [HTTPCookie])
    case checkSession(sessionId: String)
    case auth(redirectUri: String?,
              authCode: String?,
              sessionId: String,
              state: String?,
              deviceInfo: String?,
              orderId: String?,
              amount: Int?,
              currency: String?,
              mobilePhone: String?,
              orderNumber: String?,
              description: String?,
              expiry: String?,
              frequency: Int?,
              userName: String?,
              merchantLogin: String?,
              resourceName: String,
              authCookie: [HTTPCookie])
    case revokeToken(authCookie: [HTTPCookie])
}

extension AuthTarget: TargetType {
    var path: String {
        switch self {
        case .getSessionId:
            return "sdk-gateway/v1/sessionId"
        case .checkSession:
            return "sdk-gateway/v1/sessionStatus"
        case .auth:
            return "/sberpay-auth/v2/sdkAuth"
        case .revokeToken:
            return "sdk-gateway/v1/revokeTokenSdk"
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
        case .revokeToken:
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
                               authCookie: authCookie):
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
            return .requestWithParametersAndCookie(nil, bodyParameters: params, cookies: authCookie)
        case .checkSession(sessionId: let sessionId):
            let params = [
                "sessionId": sessionId
            ]
            return .requestWithParametersAndHeaders(params, headers: headers)
        case let .auth(redirectUri: redirectUri,
                       authCode: authCode,
                       sessionId: sessionId,
                       state: state,
                       deviceInfo: deviceInfo,
                       orderId: orderId,
                       amount: amount,
                       currency: currency,
                       mobilePhone: mobilePhone,
                       orderNumber: orderNumber,
                       description: description,
                       expiry: expiry,
                       frequency: frequency,
                       userName: userName,
                       merchantLogin: merchantLogin,
                       resourceName: resourceName,
                       authCookie: authCookie):
            
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
            
            if let amount = amount,
               amount != 0,
               let currency = currency,
               let orderNumber = orderNumber {
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
                    let recurrent: [String: Any] = [
                        "enabled": true,
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
            
            params["resourceName"] = resourceName
            
            return .requestWithParametersAndCookie(nil, bodyParameters: params, cookies: authCookie)
        case let .revokeToken(authCookie: authCookie):
            return .requestWithParametersAndCookie(nil, bodyParameters: nil, cookies: authCookie)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getSessionId:
            return try? Data(contentsOf: Files.sessionIdJson.url)
        case .checkSession:
            return nil
        case .auth:
            return try? Data(contentsOf: Files.authJson.url)
        case .revokeToken:
            return nil
        }
    }
}
