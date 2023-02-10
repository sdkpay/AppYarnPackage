//
//  SBPaymentTokenResponse.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 28.11.2022.
//

import Foundation

@objc(SBPaymentTokenResponse)
public final class SBPaymentTokenResponse: NSObject {
    /// Платежный токен. Отсутствует, если заполнен paymentTokenId
    @objc public var paymentToken: String?
    /// Идентификатор платежного токена. Отсутствует, если заполнен paymentToken
    @objc public var paymentTokenId: String?
    /// Срок действия платежного токена в формате UNIX (POSIX) времени
    @objc public var tokenExpiration: Int
    /// Ошибка получения токена
    @objc public var error: SBPError?
    
    @objc
    public init(paymentToken: String? = nil,
                paymentTokenId: String? = nil,
                tokenExpiration: Int = 0,
                error: SBPError? = nil) {
        self.paymentToken = paymentToken
        self.paymentTokenId = paymentTokenId
        self.tokenExpiration = tokenExpiration
        self.error = error
    }
}
