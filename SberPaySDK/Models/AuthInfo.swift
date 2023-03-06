//
//  AuthInfo.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.02.2023.
//

import Foundation

struct AuthInfo {
    let apiKey: String
    let merchantLogin: String?
    let orderId: String?
    let clientId: String?
    let redirectUri: String
    let amount: Int?
    let currency: String?
    let orderNumber: String?
    let expiry: String?
    let frequency: Int?
    
    init(fullPaymentRequest: SBFullPaymentRequest) {
        self.apiKey = fullPaymentRequest.apiKey
        self.merchantLogin = fullPaymentRequest.merchantLogin
        self.orderId = fullPaymentRequest.orderId
        self.clientId = fullPaymentRequest.clientId
        self.redirectUri = fullPaymentRequest.redirectUri
        self.amount = fullPaymentRequest.amount
        self.currency = fullPaymentRequest.currency
        self.orderNumber = nil
        self.expiry = nil
        self.frequency = nil
    }
    
    init(paymentTokenRequest: SBPaymentTokenRequest) {
        self.apiKey = paymentTokenRequest.apiKey
        self.merchantLogin = paymentTokenRequest.merchantLogin
        self.orderId = paymentTokenRequest.orderId
        self.orderNumber = paymentTokenRequest.orderNumber
        self.clientId = paymentTokenRequest.clientId
        self.redirectUri = paymentTokenRequest.redirectUri
        self.amount = paymentTokenRequest.amount
        self.currency = paymentTokenRequest.currency
        self.expiry = paymentTokenRequest.recurrentExipiry
        self.frequency = paymentTokenRequest.recurrentFrequency
    }
}
