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
    let orderId: String
    /// clientId
    let clientId: String?
    /// redirectUri
    let redirectUri: String
    
    init(fullPaymentRequest: SBFullPaymentRequest) {
        self.apiKey = fullPaymentRequest.apiKey
        self.clientName = fullPaymentRequest.clientName
        self.orderId = fullPaymentRequest.orderId
        self.clientId = fullPaymentRequest.clientId
        self.redirectUri = fullPaymentRequest.redirectUri
    }
    
    init(paymentTokenRequest: SBPaymentTokenRequest) {
        self.apiKey = paymentTokenRequest.apiKey
        self.clientName = paymentTokenRequest.clientName
        self.orderId = paymentTokenRequest.orderNumber
        self.clientId = paymentTokenRequest.clientId
        self.redirectUri = paymentTokenRequest.redirectUri
    }
}
