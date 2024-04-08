//
//  SDKManager.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 30.11.2022.
//

import UIKit

enum PayStrategy {
    case auto
    case manual
    case partPay
    case withoutRefresh
}

extension Notification.Name {
    static let closeSDKNotification = NSNotification.Name("CloseSDKWithoutError")
}

final class SDKManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(SDKManager.self)
    
    func register(in container: LocatorService) {
        let service: SDKManager = DefaultSDKManager(authManager: container.resolve(),
                                                    completionManager: container.resolve())
        container.register(service: service)
    }
}

protocol SDKManager {
    var payStrategy: PayStrategy { get }
    var authInfo: AuthInfo? { get }
    var payHandler: ((PayInfo) -> Void)? { get set }
    func config(apiKey: String,
                paymentTokenRequest: SPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion)
    func configWithBankInvoiceId(apiKey: String,
                                 paymentRequest: SBankInvoicePaymentRequest,
                                 completion: @escaping PaymentCompletion)
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion)
    func configPartPay(apiKey: String,
                       paymentRequest: SBankInvoicePaymentRequest,
                       completion: @escaping PaymentCompletion)
    func configWithoutRefresh(apiKey: String,
                              paymentRequest: SBankInvoicePaymentRequest,
                              completion: @escaping PaymentCompletion)
}

final class DefaultSDKManager: SDKManager {
    private var authManager: AuthManager
    private var completionManager: CompletionManager

    private(set) var authInfo: AuthInfo?
    private(set) var payInfo: PayInfo?
    
    var payHandler: ((PayInfo) -> Void)?

    private(set) var payStrategy: PayStrategy = .auto
    
    init(authManager: AuthManager,
         completionManager: CompletionManager) {
        self.authManager = authManager
        self.completionManager = completionManager
        SBLogger.log(.start(obj: self))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeSdk),
                                               name: .closeSDKNotification,
                                               object: nil)
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
        NotificationCenter.default.removeObserver(self, name: .closeSDKNotification, object: nil)
    }

    func config(apiKey: String,
                paymentTokenRequest: SPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion) {
        let authInfo = AuthInfo(paymentTokenRequest: paymentTokenRequest)
        self.authInfo = authInfo
        payStrategy = .manual
        authManager.apiKey = apiKey
        authManager.initialApiKey = apiKey
        authManager.lang = paymentTokenRequest.language
        authManager.orderNumber = paymentTokenRequest.orderNumber
        completionManager.setPaymentTokenCompletion(completion)
    }
    
    func configWithBankInvoiceId(apiKey: String,
                                 paymentRequest: SBankInvoicePaymentRequest,
                                 completion: @escaping PaymentCompletion) {
        let authInfo = AuthInfo(fullPaymentRequest: paymentRequest)
        self.authInfo = authInfo
        payStrategy = .auto
        authManager.apiKey = apiKey
        authManager.initialApiKey = apiKey
        authManager.lang = paymentRequest.language
        authManager.orderNumber = paymentRequest.orderNumber
        completionManager.setPaymentCompletion(completion)
    }
    
    func configWithoutRefresh(apiKey: String,
                              paymentRequest: SBankInvoicePaymentRequest,
                              completion: @escaping PaymentCompletion) {
        let authInfo = AuthInfo(fullPaymentRequest: paymentRequest)
        self.authInfo = authInfo
        payStrategy = .withoutRefresh
        authManager.apiKey = apiKey
        authManager.initialApiKey = apiKey
        authManager.lang = paymentRequest.language
        authManager.orderNumber = paymentRequest.orderNumber
        completionManager.setPaymentCompletion(completion)
    }
    
    func configPartPay(apiKey: String,
                       paymentRequest: SBankInvoicePaymentRequest,
                       completion: @escaping PaymentCompletion) {
        let authInfo = AuthInfo(fullPaymentRequest: paymentRequest)
        self.authInfo = authInfo
        payStrategy = .partPay
        authManager.apiKey = apiKey
        authManager.initialApiKey = apiKey
        authManager.lang = paymentRequest.language
        authManager.orderNumber = paymentRequest.orderNumber
        completionManager.setPaymentCompletion(completion)
    }
    
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion) {
        payInfo = PayInfo(paymentRequest: paymentRequest)
        authInfo?.orderId = paymentRequest.orderId
        completionManager.setPaymentCompletion(completion)
        payHandler?(PayInfo(paymentRequest: paymentRequest))
    }
    
    @objc private func closeSdk() {
        completionManager.closeAction()
    }
}
