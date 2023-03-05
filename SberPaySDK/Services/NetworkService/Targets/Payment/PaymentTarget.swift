//
//  PaymentTarget.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

enum PaymentTarget {
    case getPaymentToken(sessionId: String,
                         deviceInfo: String,
                         paymentId: String,
                         userName: String?,
                         merchantLogin: String?,
                         orderId: String?,
                         amount: Int?,
                         currency: String?,
                         orderNumber: String?)
    case getPaymentOrder(operationId: String,
                         orderId: String?,
                         merchantLogin: String?,
                         paymentToken: String?)
}

extension PaymentTarget: TargetType {
    var path: String {
        switch self {
        case .getPaymentToken:
            return "/paymentToken"
        case .getPaymentOrder:
            return "/paymentOrderSDK"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getPaymentToken, .getPaymentOrder:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case let .getPaymentToken(sessionId: sessionId,
                                  deviceInfo: deviceInfo,
                                  paymentId: paymentId,
                                  userName: userName,
                                  merchantLogin: merchantLogin,
                                  orderId: orderId,
                                  amount: amount,
                                  currency: currency,
                                  orderNumber: orderNumber):
            var params: [String: Any] = [
                "sessionId": sessionId,
                "deviceInfo": deviceInfo,
                "paymentId": paymentId
            ]
            
            if let orderId = orderId {
                params["orderId"] = orderId
            }
            
            if let amount = amount,
               amount != 0,
               let currency = currency,
               let orderNumber = orderNumber {
                let purchaceParams: [String: Any] = [
                    "amount": amount,
                    "currency": currency,
                    "orderNumber": orderNumber
                ]
                params["purchase"] = purchaceParams
            }
            
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            if let userName = userName {
                params["userName"] = userName
            }
            return .requestWithParameters(nil, bodyParameters: params)
        case let .getPaymentOrder(operationId: operationId,
                                  orderId: orderId,
                                  merchantLogin: merchantLogin,
                                  paymentToken: paymentToken):
            var params = [
                "operationId": operationId
            ]
            
            if let paymentToken = paymentToken {
                params["paymentToken"] = paymentToken
            }
            
            if let orderId = orderId {
                params["orderId"] = orderId
            }
    
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            return .requestWithParameters(nil, bodyParameters: params)
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getPaymentToken:
            return StubbedResponse.paymentToken.data
        case .getPaymentOrder:
            return StubbedResponse.paymentOrderSDK.data
        }
    }
}
