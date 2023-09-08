//
//  AuthInfo.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.02.2023.
//

import Foundation

struct AuthInfo: Hashable {
    let merchantLogin: String?
    var orderId: String?
    let redirectUri: String
    let amount: Int?
    let currency: String?
    let orderNumber: String?
    let expiry: String?
    let frequency: Int?
    
    init(fullPaymentRequest: SFullPaymentRequest) {
        self.merchantLogin = fullPaymentRequest.merchantLogin
        self.orderId = fullPaymentRequest.orderId
        self.redirectUri = UriValidator.validateUri(fullPaymentRequest.redirectUri)
        self.amount = nil
        self.currency = nil
        self.orderNumber = nil
        self.expiry = nil
        self.frequency = nil
    }
    
    init(fullPaymentRequest: SBankInvoicePaymentRequest) {
        self.merchantLogin = fullPaymentRequest.merchantLogin
        self.orderId = fullPaymentRequest.bankInvoiceId
        self.redirectUri = fullPaymentRequest.redirectUri
        self.amount = nil
        self.currency = nil
        self.orderNumber = nil
        self.expiry = nil
        self.frequency = nil
    }
    
    init(paymentTokenRequest: SPaymentTokenRequest) {
        self.merchantLogin = paymentTokenRequest.merchantLogin
        self.orderId = paymentTokenRequest.orderId
        self.orderNumber = paymentTokenRequest.orderNumber
        self.redirectUri = UriValidator.validateUri(paymentTokenRequest.redirectUri)
        self.amount = paymentTokenRequest.amount
        self.currency = paymentTokenRequest.currency
        self.expiry = paymentTokenRequest.recurrentExipiry
        self.frequency = paymentTokenRequest.recurrentFrequency
    }
}
