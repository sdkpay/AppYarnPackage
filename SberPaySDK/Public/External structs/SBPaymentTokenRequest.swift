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
    /// Логин дочернего партнера
    let merchantLogin: String?
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
    /// Дата прекращения действия рекуррентных платежей (формат YYYYMMDD)
    let recurrentExipiry: String?
    /// Период рекуррентных платежей в днях (натуральное число в пределах от 1 до 28)
    let recurrentFrequency: Int
    /// Cсылка для редиректа обратно в приложение
    let redirectUri: String
    
    @objc
    init(apiKey: String,
         merchantLogin: String?,
         amount: Int = 0,
         currency: String? = nil,
         orderId: String? = nil,
         mobilePhone: String? = nil,
         orderNumber: String? = nil,
         orderDescription: String? = nil,
         language: String? = nil,
         recurrentExipiry: String? = nil,
         recurrentFrequency: Int,
         redirectUri: String) {
        self.apiKey = apiKey
        self.merchantLogin = merchantLogin
        self.amount = amount
        self.currency = currency
        self.mobilePhone = mobilePhone
        self.orderNumber = orderNumber
        self.orderDescription = orderDescription
        self.language = language
        self.orderId = orderId
        self.recurrentExipiry = recurrentExipiry
        self.recurrentFrequency = recurrentFrequency
        self.redirectUri = redirectUri
    }
    
    // With orderId
    @objc
    public convenience init(apiKey: String,
                            merchantLogin: String?,
                            orderId: String,
                            redirectUri: String) {
        self.init(apiKey: apiKey,
                  merchantLogin: merchantLogin,
                  currency: nil,
                  orderId: orderId,
                  mobilePhone: nil,
                  orderNumber: nil,
                  orderDescription: nil,
                  language: nil,
                  recurrentExipiry: nil,
                  recurrentFrequency: 0,
                  redirectUri: redirectUri)
    }
    
    // With purchase
    @objc
    public convenience init(apiKey: String,
                            redirectUri: String,
                            merchantLogin: String?,
                            amount: Int,
                            currency: String,
                            mobilePhone: String?,
                            orderNumber: String,
                            recurrentExipiry: String,
                            recurrentFrequency: Int) {
        self.init(apiKey: apiKey,
                  merchantLogin: merchantLogin,
                  amount: amount,
                  currency: currency,
                  mobilePhone: mobilePhone,
                  orderNumber: orderNumber,
                  recurrentExipiry: recurrentExipiry,
                  recurrentFrequency: recurrentFrequency,
                  redirectUri: redirectUri)
    }
}
