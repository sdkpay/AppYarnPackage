//
//  UserTarget.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum UserTarget {
    case getListCards(sessionId: String,
                      merchantLogin: String?,
                      orderId: String?,
                      amount: Int?,
                      currency: String?,
                      orderNumber: String?,
                      expiry: String?,
                      frequency: Int?,
                      priorityCardOnly: Bool)
}

extension UserTarget: TargetType {
    var path: String {
        switch self {
        case .getListCards:
            return "sdk-gateway/v2/listCards"
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
        case let .getListCards(sessionId: sessionId,
                               merchantLogin: merchantLogin,
                               orderId: orderId,
                               amount: amount,
                               currency: currency,
                               orderNumber: orderNumber,
                               expiry: expiry,
                               frequency: frequency,
                               priorityCardOnly: priorityCardOnly):
            var params: [String: Any] = [
                "sessionId": sessionId
            ]
            
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            if let orderId = orderId {
                params["orderId"] = orderId
            }
            
            params["priorityCardOnly"] = priorityCardOnly
            
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
