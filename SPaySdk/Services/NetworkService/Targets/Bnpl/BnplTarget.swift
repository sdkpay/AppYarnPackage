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
}

extension BnplTarget: TargetType {
    var path: String {
        switch self {
        case .getBnplPlan:
            return "sdk-gateway/v1/paymentPlanBnpl"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getBnplPlan:
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
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getBnplPlan:
            return try? Data(contentsOf: Files.paymentPlanBnplJson.url)
        }
    }
}
