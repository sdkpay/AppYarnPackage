//
//  AuthInfo.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.02.2023.
//

import Foundation

struct AuthInfo: Hashable {
    let apiKey: String
    let merchantLogin: String?
    let orderId: String?
    let redirectUri: String
    let amount: Int?
    let currency: String?
    let orderNumber: String?
    let expiry: String?
    let frequency: Int?
    
    init(fullPaymentRequest: SFullPaymentRequest) {
        self.apiKey = fullPaymentRequest.apiKey
        self.merchantLogin = fullPaymentRequest.merchantLogin
        self.orderId = fullPaymentRequest.orderId
        self.redirectUri = fullPaymentRequest.redirectUri
        self.amount = nil
        self.currency = nil
        self.orderNumber = nil
        self.expiry = nil
        self.frequency = nil
    }
    
    init(paymentTokenRequest: SPaymentTokenRequest) {
        self.apiKey = paymentTokenRequest.apiKey
        self.merchantLogin = paymentTokenRequest.merchantLogin
        self.orderId = paymentTokenRequest.orderId
        self.orderNumber = paymentTokenRequest.orderNumber
        self.redirectUri = paymentTokenRequest.redirectUri
        self.amount = paymentTokenRequest.amount
        self.currency = paymentTokenRequest.currency
        self.expiry = paymentTokenRequest.recurrentExipiry
        self.frequency = paymentTokenRequest.recurrentFrequency
    }
}
