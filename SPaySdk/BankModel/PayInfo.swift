//
//  PayInfo.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.02.2023.
//

import Foundation

struct PayInfo {
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    let apiKey: String
    /// Уникальный номер (идентификатор) заказа в Платежном шлюзе Банка.
    let orderId: String
    /// Платежный токен, полученный от SDK.
    let paymentToken: String?
    /// Идентификатор платежного токена, полученный от SDK.
    let paymentTokenId: String?
    
    init(paymentRequest: SBPaymentRequest) {
        self.apiKey = paymentRequest.apiKey
        self.orderId = paymentRequest.orderId
        self.paymentToken = paymentRequest.paymentToken
        self.paymentTokenId = paymentRequest.paymentTokenId
    }
}
