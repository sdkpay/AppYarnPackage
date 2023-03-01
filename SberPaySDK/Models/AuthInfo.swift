//
//  AuthInfo.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.02.2023.
//

import Foundation

struct AuthInfo {
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    let apiKey: String
    /// Идентификатора плательщика в вашей системе
    let clientName: String
    /// Сумма операции в минорных единицах
    let orderId: String?
    /// clientId
    let clientId: String?
    /// redirectUri
    let redirectUri: String
    /// redirectUri
    let amount: Int?
    let currency: String?
    let orderNumber: String?
    
    init(fullPaymentRequest: SBFullPaymentRequest) {
        self.apiKey = fullPaymentRequest.apiKey
        self.clientName = fullPaymentRequest.clientName
        self.orderId = fullPaymentRequest.orderId
        self.clientId = fullPaymentRequest.clientId
        self.redirectUri = fullPaymentRequest.redirectUri
        self.amount = fullPaymentRequest.amount
        self.currency = fullPaymentRequest.currency
        self.orderNumber = nil
    }
    
    init(paymentTokenRequest: SBPaymentTokenRequest) {
        self.apiKey = paymentTokenRequest.apiKey
        self.clientName = paymentTokenRequest.clientName
        self.orderId = paymentTokenRequest.orderId
        self.orderNumber = paymentTokenRequest.orderNumber
        self.clientId = paymentTokenRequest.clientId
        self.redirectUri = paymentTokenRequest.redirectUri
        self.amount = paymentTokenRequest.amount
        self.currency = paymentTokenRequest.currency
    }
}
