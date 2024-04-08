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
            return "sdk-gateway/v1/confirmOtp"
        case .createOtpSdk:
            return "sdk-gateway/v1/createOtp"
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
            
            return .requestWithParameters(nil, bodyParameters: params)
        case let .createOtpSdk(bankInvoiceId,
                               sessionId,
                               paymentId):
            let params: [String: Any] = [
                "bankInvoiceId": bankInvoiceId,
                "sessionId": sessionId,
                "paymentId": paymentId
            ]
            return .requestWithParameters(nil, bodyParameters: params)
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        switch self {
        case .confirmOtp:
            return try? Data(contentsOf: Files.Stubs.sendOtpJson.url)
        case .createOtpSdk:
            return try? Data(contentsOf: Files.Stubs.otpJson.url)
        }
    }
}
