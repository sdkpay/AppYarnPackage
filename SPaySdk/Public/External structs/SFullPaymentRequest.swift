//
//  SBFullPaymentRequest.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import Foundation

@objc(SBankInvoiceIdPaymentRequest)
public final class SBankInvoicePaymentRequest: NSObject {
    /// Логин дочернего партнера
    let merchantLogin: String?
    /// Выбранный язык локализации интерфейсов
    let language: String?
    /// Параметр создания платежного токена для реккурентных платежей
    let redirectUri: String
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let bankInvoiceId: String
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let orderNumber: String
    /// Api key
    let apiKey: String?
    
    @objc
    public init(merchantLogin: String? = nil,
                bankInvoiceId: String,
                orderNumber: String,
                language: String? = nil,
                redirectUri: String,
                apiKey: String? = nil) {
        self.merchantLogin = merchantLogin
        self.bankInvoiceId = bankInvoiceId
        self.language = language
        self.orderNumber = orderNumber
        self.apiKey = apiKey
        self.redirectUri = redirectUri
    }
}
