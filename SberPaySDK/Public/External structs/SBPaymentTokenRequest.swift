//
//  SBPaymentTokenRequest.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 28.11.2022.
//

import Foundation

@objc(SBPaymentTokenRequest)
public final class SBPaymentTokenRequest: NSObject {
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    let apiKey: String
    /// Идентификатора плательщика в вашей системе
    let clientId: String?
    /// Название магазина клиента
    let clientName: String
    /// Сумма операции в минорных единицах
    let amount: Int?
    /// Цифровой код валюты операции согласно ISO 4217
    let currency: String?
    /// Номер мобильного телефона Плательщика, если имеется в вашей системе
    let mobilePhone: String?
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let orderNumber: String?
    /// Идентификатор заказа на стороне банка
    let orderId: String?
    /// Описание к заказу
    let orderDescription: String?
    /// Выбранный язык локализации интерфейсов
    let language: String?
    /// Параметр создания платежного токена для реккурентных платежей
    let recurrentEnabled: Bool
    /// Дата прекращения действия рекуррентных платежей (формат YYYYMMDD)
    let recurrentExipiry: String?
    /// Период рекуррентных платежей в днях (натуральное число в пределах от 1 до 28)
    let recurrentFrequency: Int
    /// Cсылка для редиректа обратно в приложение
    let redirectUri: String
    
    @objc
    public init(apiKey: String,
                clientId: String? = nil,
                clientName: String,
                amount: Int,
                currency: String,
                orderId: String? = nil,
                mobilePhone: String? = nil,
                orderNumber: String? = nil,
                orderDescription: String? = nil,
                language: String? = nil,
                recurrentEnabled: Bool,
                recurrentExipiry: String? = nil,
                recurrentFrequency: Int,
                redirectUri: String) {
        self.apiKey = apiKey
        self.clientId = clientId
        self.clientName = clientName
        self.amount = amount
        self.currency = currency
        self.mobilePhone = mobilePhone
        self.orderNumber = orderNumber
        self.orderDescription = orderDescription
        self.language = language
        self.orderId = orderId
        self.recurrentEnabled = recurrentEnabled
        self.recurrentExipiry = recurrentExipiry
        self.recurrentFrequency = recurrentFrequency
        self.redirectUri = redirectUri
    }
    
    @objc
    public convenience init(apiKey: String,
                            clientName: String,
                            amount: Int,
                            currency: String,
                            orderNumber: String,
                            recurrentEnabled: Bool,
                            recurrentFrequency: Int,
                            redirectUri: String) {
        self.init(apiKey: apiKey,
                  clientId: nil,
                  clientName: clientName,
                  amount: amount,
                  currency: currency,
                  mobilePhone: nil,
                  orderNumber: orderNumber,
                  orderDescription: nil,
                  language: nil,
                  recurrentEnabled: recurrentEnabled,
                  recurrentExipiry: nil,
                  recurrentFrequency: recurrentFrequency,
                  redirectUri: redirectUri)
    }
}
