//
//  SBFullPaymentRequest.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import Foundation

@objc(SFullPaymentRequest)
public final class SFullPaymentRequest: NSObject {
    /// Логин дочернего партнера
    let merchantLogin: String?
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let orderId: String
    /// Выбранный язык локализации интерфейсов
    let language: String?
    /// Параметр создания платежного токена для реккурентных платежей
    let redirectUri: String
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let orderNumber: String

    @objc
    public init(merchantLogin: String? = nil,
                orderId: String,
                orderNumber: String,
                language: String? = nil,
                redirectUri: String) {
        self.merchantLogin = merchantLogin
        self.orderId = orderId
        self.language = language
        self.orderNumber = orderNumber
        self.redirectUri = redirectUri
    }
}
