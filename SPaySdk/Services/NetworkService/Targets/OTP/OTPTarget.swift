//
//  OTPTarget.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import Foundation

enum OTPTarget {
    case confirmOtp(bankInvoiceId: String,
                    otpHash: String,
                    merchantLogin: String?,
                    sessionId: String?)
    case createOtpSdk(bankInvoiceId: String,
                      sessionId: String,
                      paymentId: Int)
}

extension OTPTarget: TargetType {
    var path: String {
        switch self {
        case .confirmOtp:
            return "/confirmOtp"
        case .createOtpSdk:
            return "/createOtpSdk"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .confirmOtp:
            return .post
        case .createOtpSdk:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case let .confirmOtp(bankInvoiceId,
                             otpHash,
                             merchantLogin,
                             sessionId):
            var params: [String: Any] = [
                "bankInvoiceId": bankInvoiceId,
                "otpHash": otpHash
            ]
            
            if let merchantLogin {
                params["merchantLogin"] = merchantLogin
            }
            
            if let sessionId {
                params["sessionId"] = sessionId
            }
            
            return .requestWithParameters(params)
        case let .createOtpSdk(bankInvoiceId,
                               sessionId,
                               paymentId):
            let params: [String: Any] = [
                "bankInvoiceId": bankInvoiceId,
                "sessionId": sessionId,
                "paymentId": paymentId
            ]
            return .requestWithParameters(params)
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        nil
    }
}
