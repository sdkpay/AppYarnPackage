//
//  SBPay.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import UIKit

@objc
public final class SBPay: NSObject {
    private static var payService: SBPayService? = DefaultSBPayService()
    /**
     Проверяет наличие установленного МП СБОЛ или Сбербанк Онлайн на устройстве
    
     Требуется задать LSApplicationQueriesSchemes в Info.plist
     */
    @objc
    public static var isReadyForSberPay: Bool {
         payService?.isReadyForSberPay ?? false
    }
    
    /**
     Метод получения PaymentToken
     */
    @objc
    public static func getPaymentToken(with paymentTokenRequest: SBPaymentTokenRequest,
                                       completion: @escaping (SBPaymentTokenResponse) -> Void) {
        payService?.getPaymentToken(with: paymentTokenRequest, completion: completion)
    }
    
    /**
     Метод для оплаты
     */
    @objc
    public static func pay(with paymentRequest: SBPaymentRequest,
                           completion: @escaping (_ error: SBPError?) -> Void) {
        payService?.pay(with: paymentRequest, completion: completion)
    }
    
    /**
     Единый метод для оплаты
     */
    @objc
    public static func payWithOrderId(paymentRequest: SBFullPaymentRequest,
                                      completion: @escaping (_ error: SBPError?) -> Void) {
        payService?.payWithOrderId(paymentRequest: paymentRequest, completion: completion)
    }
    
    /**
     Метод для завершения оплаты и закрытия окна SDK
     */
    @objc
    public static func completePayment(paymentSuccess: Bool,
                                       completion: @escaping () -> Void) {
        payService?.completePayment(paymentSuccess: paymentSuccess, completion: completion)
    }
    
    /**
     Метод для авторизации SBOL необходимо интегрировать в AppDelegate
     */
    @objc
    public static func getAuthURL(_ url: URL) {
        payService?.getResponseFrom(url)
    }
}
