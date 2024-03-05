//
//  BnplTarget.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

enum BnplTarget {
    case getBnplPlan(sessionId: String,
                     merchantLogin: String,
                     orderId: String)
    case createPaymentPlan(sessionId: String,
                           merchantLogin: String,
                           orderId: String)
}

extension BnplTarget: TargetType {
    var path: String {
        switch self {
        case .getBnplPlan:
            return "sdk-gateway/v2/paymentPlanBnpl"
        case .createPaymentPlan:
            return "sdk-gateway/v1/createPaymentPlan"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getBnplPlan, .createPaymentPlan:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case let .getBnplPlan(sessionId: sessionId,
                              merchantLogin: merchantLogin,
                              orderId: orderId):
            let params: [String: Any] = [
                "sessionId": sessionId,
                "merchantLogin": merchantLogin,
                "orderId": orderId
            ]
            return .requestWithParameters(nil, bodyParameters: params)
        case let .createPaymentPlan(sessionId: sessionId,
                                    merchantLogin: merchantLogin,
                                    orderId: orderId):
            let params: [String: Any] = [
                "sessionId": sessionId,
                "merchantLogin": merchantLogin,
                "orderId": orderId
            ]
            return .requestWithParameters(nil, bodyParameters: params)
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getBnplPlan:
            return try? Data(contentsOf: Files.Stubs.paymentPlanBnplJson.url)
        case .createPaymentPlan:
            return try? Data(contentsOf: Files.Stubs.createPaymentPlanJson.url)
        }
    }
}
