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
    /// Идентификатора плательщика в вашей системе
    let clientId: String?
    /// Название магазина клиента
    let clientName: String
    /// Сумма операции в минорных единицах
    let amount: Int
    /// Цифровой код валюты операции согласно ISO 4217
    let currency: Int
    /// Номер мобильного телефона Плательщика, если имеется в вашей системе
    let mobilePhone: String?
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let orderId: String
    /// Описание к заказу
    let orderDescription: String?
    /// Выбранный язык локализации интерфейсов
    let language: String?
    /// Параметр создания платежного токена для реккурентных платежей
    let redirectUri: String

    @objc
    public init(apiKey: String,
                clientId: String? = nil,
                clientName: String,
                amount: Int,
                currency: Int,
                mobilePhone: String? = nil,
                orderId: String,
                orderDescription: String? = nil,
                language: String? = nil,
                redirectUri: String) {
        self.apiKey = apiKey
        self.clientId = clientId
        self.clientName = clientName
        self.amount = amount
        self.currency = currency
        self.mobilePhone = mobilePhone
        self.orderId = orderId
        self.orderDescription = orderDescription
        self.language = language
        self.redirectUri = redirectUri
    }
}
