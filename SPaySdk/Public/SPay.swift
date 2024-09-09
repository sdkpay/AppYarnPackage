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
    
    private static var payService: SBPayService?
    
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    @objc
    public static func setup(bnplPlan: Bool = true,
                             spasiboBonuses: Bool = true,
                             resultViewNeeded: Bool = true,
                             helpers: Bool = true,
                             needLogs: Bool = true,
                             helperConfig: SBHelperConfig = SBHelperConfig(),
                             environment: SEnvironment = .prod,
                             completion: ((SPError?) -> Void)? = nil) {
        
        if payService == nil {
            payService = DefaultSBPayService()
        }
        payService?.setup(bnplPlan: bnplPlan,
                          spasiboBonuses: spasiboBonuses,
                          resultViewNeeded: resultViewNeeded,
                          helpers: helpers,
                          needLogs: needLogs,
                          config: helperConfig,
                          environment: environment,
                          completion: completion)
    }
    
    /**
     Метод проверки доступности сервисов оплаты 
     */
    @objc
    public static var isReadyForSPay: Bool {
         payService != nil
    }
    
    /**
     Единый метод для оплаты
     */
    @objc
    public static func payWithBankInvoiceId(with viewController: UIViewController,
                                            paymentRequest: SBankInvoicePaymentRequest,
                                            completion: @escaping (_ state: SPayState,
                                                                   _ info: String,
                                                                   _ localSessionId: String?) -> Void) {
        payService?.payWithBankInvoiceId(with: viewController, paymentRequest: paymentRequest, completion: completion)
    }
    
    /**
    Метод оплаты только для оплаты частями
     */
    @objc
    public static func payWithoutRefresh(with viewController: UIViewController,
                                         paymentRequest: SBankInvoicePaymentRequest,
                                         completion: @escaping (_ state: SPayState,
                                                                _ info: String,
                                                                _ localSessionId: String?) -> Void) {
        payService?.payWithoutRefresh(with: viewController, paymentRequest: paymentRequest, completion: completion)
    }
    
    /**
     Метод оплаты только для оплаты частями
     */
    @objc
    public static func payWithPartPay(with viewController: UIViewController,
                                      paymentRequest: SBankInvoicePaymentRequest,
                                      completion: @escaping (_ state: SPayState,
                                                             _ info: String,
                                                             _ localSessionId: String?) -> Void) {
        payService?.payWithPartPay(with: viewController, paymentRequest: paymentRequest, completion: completion)
    }
    
    // Новые методы работающие на window
    
    @objc
    public static func payWithBankInvoiceId(paymentRequest: SBankInvoicePaymentRequest,
                                            completion: @escaping (_ state: SPayState,
                                                                   _ info: String,
                                                                   _ localSessionId: String?) -> Void) {
        payService?.payWithBankInvoiceId(paymentRequest: paymentRequest, completion: completion)
    }
    
    @objc
    public static func payWithoutRefresh(paymentRequest: SBankInvoicePaymentRequest,
                                         completion: @escaping (_ state: SPayState,
                                                                _ info: String,
                                                                _ localSessionId: String?) -> Void) {
        payService?.payWithoutRefresh(paymentRequest: paymentRequest, completion: completion)
    }
    
    @objc
    public static func payWithPartPay(paymentRequest: SBankInvoicePaymentRequest,
                                      completion: @escaping (_ state: SPayState,
                                                             _ info: String,
                                                             _ localSessionId: String?) -> Void) {
        payService?.payWithPartPay(paymentRequest: paymentRequest, completion: completion)
    }

    /**
     Метод для авторизации банка необходимо интегрировать в AppDelegate
     */
    @objc
    public static func getAuthURL(_ url: URL) {
        payService?.getResponseFrom(url)
    }
    
    /**
     Метод для передачи
     */
    @objc
    public static func setBankScheme(_ url: URL) throws {
        try payService?.setBankScheme(url)
    }
    
    /**
     Метод для установки моков, только для тестовых версий
     */
#if SDKDEBUG
    public static func debugConfig(network: NetworkState,
                                   ssl: Bool,
                                   refresh: Bool,
                                   debugLogLevel: [DebugLogLevel]) {
        
        if payService == nil {
            payService = DefaultSBPayService()
        }
        payService?.debugConfig(network: network, ssl: ssl, refresh: refresh, debugLogLevel: debugLogLevel)
    }
#endif
}
