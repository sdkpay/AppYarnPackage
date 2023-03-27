//
//  StubbedResponse.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum StubbedResponse {
    case config, auth, listCards, paymentToken, paymentOrderSDK

    var data: Data {
        switch self {
        case .config:
            return stubbedResponse("RemoteConfig")
        case .auth:
            return stubbedResponse("Auth")
        case .listCards:
            return stubbedResponse("ListCards")
        case .paymentToken:
            return stubbedResponse("PaymentToken")
        case .paymentOrderSDK:
            return stubbedResponse("PaymentOrderSDK")
        }
    }
    
    private func stubbedResponse(_ filename: String) -> Data! {
        let path = Bundle(for: SBPay.self).path(forResource: filename,
                                                ofType: "json")
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path!))
        } catch {
            fatalError(" \(filename) file not found")
        }
    }
}
