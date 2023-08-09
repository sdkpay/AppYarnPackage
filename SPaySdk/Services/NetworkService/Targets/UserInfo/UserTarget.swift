//
//  UserTarget.swift
//  SPaySdk
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
                        orderId: String?,
                        amount: Int?,
                        currency: String?,
                        orderNumber: String?,
                        expiry: String?,
                        frequency: Int?,
                        listPaymentCards: Bool?)
}

extension UserTarget: TargetType {
    var path: String {
        switch self {
        case .getListCards:
            return "/listCards"
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
                               authCode: authCode,
                               sessionId: sessionId,
                               state: state,
                               merchantLogin: merchantLogin,
                               orderId: orderId,
                               amount: amount,
                               currency: currency,
                               orderNumber: orderNumber,
                               expiry: expiry,
                               frequency: frequency,
                               listPaymentCards: listPaymentCards):
            var params: [String: Any] = [
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
            
            params["listPaymentCards"] = listPaymentCards == nil ? false : listPaymentCards
            
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
            
            params["orderId"] = orderId
            
            return .requestWithParametersAndHeaders(nil, bodyParameters: params)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getListCards:
            return try? Data(contentsOf: Files.listCardsJson.url)
        }
    }
}
