//
//  SBFullPaymentRequest.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import Foundation

@objc(SBFullPaymentRequest)
public final class SBFullPaymentRequest: NSObject {
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    let apiKey: String
    /// Логин дочернего партнера
    let merchantLogin: String?
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let orderId: String
    /// Выбранный язык локализации интерфейсов
    let language: String?
    /// Параметр создания платежного токена для реккурентных платежей
    let redirectUri: String

    @objc
    public init(apiKey: String,
                merchantLogin: String? = nil,
                orderId: String,
                language: String? = nil,
                redirectUri: String) {
        self.apiKey = apiKey
        self.merchantLogin = merchantLogin
        self.orderId = orderId
        self.language = language
        self.redirectUri = redirectUri
    }
}
