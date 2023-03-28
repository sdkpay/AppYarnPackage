//
//  SBPaymentRequest.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.11.2022.
//

import Foundation

@objc(SPaymentRequest)
public final class SPaymentRequest: NSObject {
    /// Уникальный номер (идентификатор) заказа в Платежном шлюзе Банка.
    let orderId: String
    /// Платежный токен, полученный от SDK.
    let paymentToken: String?
    /// Идентификатор платежного токена, полученный от SDK.
    let paymentTokenId: String?
    
    @objc
    init(orderId: String,
         paymentToken: String?,
         paymentTokenId: String?) {
        self.orderId = orderId
        self.paymentToken = paymentToken
        self.paymentTokenId = paymentTokenId
    }
    
    @objc
    public convenience init(orderId: String,
                            paymentToken: String) {
        self.init(orderId: orderId,
                  paymentToken: paymentToken,
                  paymentTokenId: nil)
    }
    
    @objc
    public convenience init(orderId: String,
                            paymentTokenId: String) {
        self.init(orderId: orderId,
                  paymentToken: nil,
                  paymentTokenId: paymentTokenId)
    }
}
