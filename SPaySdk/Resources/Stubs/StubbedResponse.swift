//
//  StubbedResponse.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum StubbedResponse {
    case config, auth, listCards, paymentToken, paymentOrderSDK, paymentPlanBnpl, certConfig

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
        case .paymentPlanBnpl:
            return stubbedResponse("PaymentPlanBnpl")
        case .certConfig:
            return stubbedResponse("CertConfig")
        }
    }
    
    private func stubbedResponse(_ filename: String) -> Data {
        guard let path = Bundle(for: SPay.self).path(forResource: filename,
                                                     ofType: "json") else { return Data() }
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            fatalError(" \(filename) file not found")
        }
    }
}
