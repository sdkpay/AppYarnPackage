//
//  PaymentTarget.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

enum PaymentTarget {
    case getPaymentToken(sessionId: String,
                         deviceInfo: String,
                         paymentId: Int,
                         merchantLogin: String?,
                         orderId: String?,
                         amount: Int?,
                         currency: String?,
                         orderNumber: String?,
                         expiry: String?,
                         frequency: Int?,
                         resolution: String?,
                         isBnplEnabled: Bool)
    case getPaymentOrder(operationId: String,
                         orderId: String?,
                         merchantLogin: String?,
                         ipAddress: String?,
                         paymentToken: String?)
}

extension PaymentTarget: TargetType {
    var path: String {
        switch self {
        case .getPaymentToken:
            return "sdk-gateway/v1/paymentToken"
        case .getPaymentOrder:
            return "sdk-gateway/v1/paymentOrder"
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
                                  merchantLogin: merchantLogin,
                                  orderId: orderId,
                                  amount: amount,
                                  currency: currency,
                                  orderNumber: orderNumber,
                                  expiry: expiry,
                                  frequency: frequency,
                                  resolution: resolution,
                                  isBnplEnabled):
            var params: [String: Any] = [
                "sessionId": sessionId,
                "deviceInfo": deviceInfo,
                "paymentId": paymentId
            ]
            
            if let resolution {
                let fraudMonInfo: [String: Any] = [
                    "resolution": resolution
                ]
                
                params["fraudMonInfo"] = fraudMonInfo
            }
            
            if isBnplEnabled {
                params["isBnplEnabled"] = isBnplEnabled
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
            
            if let merchantLogin = merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            return .requestWithParameters(nil, bodyParameters: params)
        case let .getPaymentOrder(operationId: operationId,
                                  orderId: orderId,
                                  merchantLogin: merchantLogin,
                                  ipAddress: ipAddress,
                                  paymentToken: paymentToken):
            var params: [String: Any] = [
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
            
            if let ipAddress = ipAddress {
                let jsonParams = [
                    "ip": ipAddress
                ]
                params["jsonParams"] = jsonParams
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
            return try? Data(contentsOf: Files.Stubs.paymentTokenJson.url)
        case .getPaymentOrder:
            return try? Data(contentsOf: Files.Stubs.paymentOrderSDKJson.url)
        }
    }
}
