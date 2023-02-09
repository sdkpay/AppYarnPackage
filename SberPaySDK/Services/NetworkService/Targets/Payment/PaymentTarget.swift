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
                         apiKey: String,
                         userName: String,
                         merchantLogin: String,
                         orderId: String)
    case getPaymentOrder
}

extension PaymentTarget: TargetType {
    var path: String {
        switch self {
        case .getPaymentToken:
            return "sdk-gateway/v1/paymentToken"
        case .getPaymentOrder:
            return "sdk-gateway/v1/paymentOrderSDK"
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
                                  apiKey: apiKey,
                                  userName: userName,
                                  merchantLogin: merchantLogin,
                                  orderId: orderId):
            let params = [
                "sessionId": sessionId,
                "deviceInfo": deviceInfo,
                "paymentId": paymentId,
                "apiKey": apiKey,
                "userName": userName,
                "merchantLogin": merchantLogin,
                "orderId": orderId
            ]
            return .requestWithParameters(nil, bodyParameters: params)
        case .getPaymentOrder:
            return .requestWithParameters(nil, bodyParameters: nil)
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
                // DEBUG
            return StubbedResponse.listCards.data
        }
    }
}
