//
//  StubbedResponse.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum StubbedResponse {
    case auth, listCards, paymentToken

    var data: Data {
        switch self {
        case .auth:
            return stubbedResponse("Auth")
        case .listCards:
            return stubbedResponse("ListCards")
        case .paymentToken:
            return stubbedResponse("PaymentToken")
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
