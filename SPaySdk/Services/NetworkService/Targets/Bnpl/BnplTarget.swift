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
                     orderId: String,
                     redirectUri: String,
                     authCode: String,
                     state: String)
}

extension BnplTarget: TargetType {
    var path: String {
        switch self {
        case .getBnplPlan:
            return "/paymentPlanBnpl"
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
                              orderId: orderId,
                              redirectUri: redirectUri,
                              authCode: authCode,
                              state: state):
            let params: [String: Any] = [
                "sessionId": sessionId,
                "merchantLogin": merchantLogin,
                "orderId": orderId,
                "authCode": authCode,
                "state": state,
                "redirectUri": redirectUri
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
