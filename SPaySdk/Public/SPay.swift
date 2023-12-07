//
//  SBPay.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import UIKit

@objc
public enum SEnvironment: Int {
    case prod = 0
    case sandboxWithoutBankApp
    case sandboxRealBankApp
}

@objc
public final class SPay: NSObject {
    
    private static var payService: SBPayService? = DefaultSBPayService()
    
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    @objc
    public static func setup(bnplPlan: Bool = false,
                             helperConfig: SBHelperConfig = SBHelperConfig(),
                             environment: SEnvironment = .prod,
                             completion: Action? = nil) {
        payService?.setup(bnplPlan: bnplPlan, config: helperConfig, environment: environment, completion: completion)
    }
    
    /**
     Требуется задать LSApplicationQueriesSchemes в Info.plist
     */
    @objc
    public static var isReadyForSPay: Bool {
         payService?.isReadyForSPay ?? false
    }
    
    /**
     Метод получения PaymentToken
     */
    @objc
    public static func getPaymentToken(with viewController: UIViewController,
                                       with paymentTokenRequest: SPaymentTokenRequest,
                                       completion: @escaping (_ state: SPayTokenState, _ info: SPaymentTokenResponseModel) -> Void) {
        payService?.getPaymentToken(with: viewController, with: paymentTokenRequest, completion: completion)
    }
    
    /**
     Метод для оплаты
     */
    @objc
    public static func pay(with paymentRequest: SPaymentRequest,
                           completion: @escaping (_ state: SPayState, _ info: String) -> Void) {
        payService?.pay(with: paymentRequest, completion: completion)
    }
    
    /**
     Единый метод для оплаты
     */
    @objc
    public static func payWithBankInvoiceId(with viewController: UIViewController,
                                            paymentRequest: SBankInvoicePaymentRequest,
                                            completion: @escaping (_ state: SPayState, _ info: String) -> Void) {
        payService?.payWithBankInvoiceId(with: viewController, paymentRequest: paymentRequest, completion: completion)
    }
    
    /**
     Метод для завершения оплаты и закрытия окна SDK
     */
    @objc
    public static func completePayment(paymentState: SPayState,
                                       completion: @escaping () -> Void) {
        payService?.completePayment(paymentSuccess: paymentState, completion: completion)
    }
    
    /**
     Метод для авторизации банка необходимо интегрировать в AppDelegate
     */
    @objc
    public static func getAuthURL(_ url: URL) {
        payService?.getResponseFrom(url)
    }
    
    /**
     Метод для установки моков, только для тестовых версий
     */
#if SDKDEBUG
    public static func debugConfig(network: NetworkState, ssl: Bool, refresh: Bool) {
        payService?.debugConfig(network: network, ssl: ssl, refresh: refresh)
    }
#endif
}
