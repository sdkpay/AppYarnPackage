//
//  SBFullPaymentRequest.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import Foundation

#if SDKDEBUG
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
    
    @objc
    public init(merchantLogin: String? = nil,
                orderId: String,
                language: String? = nil,
                redirectUri: String) {
        self.merchantLogin = merchantLogin
        self.orderId = orderId
        self.language = language
        self.redirectUri = redirectUri
    }
}
#else
@objc(SFullPaymentRequest)
@available(*, deprecated, message: "Структура устарела, используйте SBankInvoicePaymentRequest")
public final class SFullPaymentRequest: NSObject {
    /// Логин дочернего партнера
    let merchantLogin: String?
    /// Уникальный номер (идентификатор) заказа в системе Клиента.
    let orderId: String
    /// Выбранный язык локализации интерфейсов
    let language: String?
    /// Параметр создания платежного токена для реккурентных платежей
    let redirectUri: String
    
    @objc
    public init(merchantLogin: String? = nil,
                orderId: String,
                language: String? = nil,
                redirectUri: String) {
        self.merchantLogin = merchantLogin
        self.orderId = orderId
        self.language = language
        self.redirectUri = redirectUri
    }
}
#endif

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
    
    @objc
    public init(merchantLogin: String? = nil,
                bankInvoiceId: String,
                language: String? = nil,
                redirectUri: String) {
        self.merchantLogin = merchantLogin
        self.bankInvoiceId = bankInvoiceId
        self.language = language
        self.redirectUri = redirectUri
    }
}
