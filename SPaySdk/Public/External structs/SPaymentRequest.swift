//
//  SBPaymentRequest.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.11.2022.
//

import Foundation

@objc(SPaymentRequest)
public final class SPaymentRequest: NSObject {
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    let apiKey: String
    /// Уникальный номер (идентификатор) заказа в Платежном шлюзе Банка.
    let orderId: String
    /// Платежный токен, полученный от SDK.
    let paymentToken: String?
    /// Идентификатор платежного токена, полученный от SDK.
    let paymentTokenId: String?
    
    @objc
    init(apiKey: String,
         orderId: String,
         paymentToken: String?,
         paymentTokenId: String?) {
        self.apiKey = apiKey
        self.orderId = orderId
        self.paymentToken = paymentToken
        self.paymentTokenId = paymentTokenId
    }
    
    @objc
    public convenience init(apiKey: String,
                            orderId: String,
                            paymentToken: String) {
        self.init(apiKey: apiKey,
                  orderId: orderId,
                  paymentToken: paymentToken,
                  paymentTokenId: nil)
    }
    
    @objc
    public convenience init(apiKey: String,
                            orderId: String,
                            paymentTokenId: String) {
        self.init(apiKey: apiKey,
                  orderId: orderId,
                  paymentToken: nil,
                  paymentTokenId: paymentTokenId)
    }
}
