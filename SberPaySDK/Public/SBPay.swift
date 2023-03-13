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
                           completion: @escaping (_ state: SBPayState, _ info: String) -> Void) {
        payService?.pay(with: paymentRequest, completion: completion)
    }
    
    /**
     Единый метод для оплаты
     */
    @objc
    public static func payWithOrderId(paymentRequest: SBFullPaymentRequest,
                                      completion: @escaping (_ state: SBPayState, _ info: String) -> Void) {
        payService?.payWithOrderId(paymentRequest: paymentRequest, completion: completion)
    }
    
    /**
     Метод для завершения оплаты и закрытия окна SDK
     */
    @objc
    public static func completePayment(paymentState: SBPayState,
                                       completion: @escaping () -> Void) {
        payService?.completePayment(paymentSuccess: paymentState, completion: completion)
    }
    
    /**
     Метод для авторизации SBOL необходимо интегрировать в AppDelegate
     */
    @objc
    public static func getAuthURL(_ url: URL) {
        payService?.getResponseFrom(url)
    }
    
    /**
     Метод для установки моков, только для тестовых версий
     */

    public static func debugConfig(network: NetworkState, ssl: Bool) {
        BuildSettings.shared.networkState = network
        BuildSettings.shared.ssl = ssl
    }
}
