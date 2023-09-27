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
}

extension Notification.Name {
    static let closeSDKNotification = NSNotification.Name("CloseSDKWithoutError")
}

final class SDKManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: SDKManager = DefaultSDKManager(authManager: container.resolve(),
                                                    completionManager: container.resolve())
        container.register(service: service)
    }
}

protocol SDKManager {
    var newStart: Bool { get }
    var payStrategy: PayStrategy { get }
    var authInfo: AuthInfo? { get }
    var payHandler: ((PayInfo) -> Void)? { get set }
    func config(apiKey: String,
                paymentTokenRequest: SPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion)
    func configWithOrderId(apiKey: String,
                           paymentRequest: SFullPaymentRequest,
                           completion: @escaping PaymentCompletion)
    func configWithBankInvoiceId(apiKey: String,
                                 paymentRequest: SBankInvoicePaymentRequest,
                                 completion: @escaping PaymentCompletion)
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion)
//    func completionPaymentToken(with paymentToken: String?,
//                                paymentTokenId: String?,
//                                tokenExpiration: Int)
//    func completionWithError(error: SDKError)
//    func completionPay(with state: SPayState)
}

final class DefaultSDKManager: SDKManager {
    private var authManager: AuthManager
    private var completionManager: CompletionManager

    private(set) var authInfo: AuthInfo?
    private(set) var payInfo: PayInfo?
    
    var payHandler: ((PayInfo) -> Void)?

    private(set) var payStrategy: PayStrategy = .manual
    private(set) var newStart = true
    
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
        newStart = isNewStart(check: authInfo)
        if newStart { self.authInfo = authInfo }
        payStrategy = .manual
        authManager.apiKey = apiKey
        authManager.lang = paymentTokenRequest.language
        completionManager.setPaymentTokenCompletion(completion)
    }
    
    func configWithOrderId(apiKey: String,
                           paymentRequest: SFullPaymentRequest,
                           completion: @escaping PaymentCompletion) {
        let authInfo = AuthInfo(fullPaymentRequest: paymentRequest)
        newStart = isNewStart(check: authInfo)
        if newStart { self.authInfo = authInfo }
        payStrategy = .auto
        authManager.apiKey = apiKey
        authManager.lang = paymentRequest.language
        completionManager.setPaymentCompletion(completion)
    }
    
    func configWithBankInvoiceId(apiKey: String,
                                 paymentRequest: SBankInvoicePaymentRequest,
                                 completion: @escaping PaymentCompletion) {
        let authInfo = AuthInfo(fullPaymentRequest: paymentRequest)
        newStart = isNewStart(check: authInfo)
        if newStart { self.authInfo = authInfo }
        payStrategy = .auto
        authManager.apiKey = apiKey
        authManager.lang = paymentRequest.language
        completionManager.setPaymentCompletion(completion)
    }
    
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion) {
        payInfo = PayInfo(paymentRequest: paymentRequest)
        authInfo?.orderId = paymentRequest.orderId
        completionManager.setPaymentCompletion(completion)
        payHandler?(PayInfo(paymentRequest: paymentRequest))
    }
    
//    func completionWithError(error: SDKError) {
//        let responce = SPaymentTokenResponse()
//        responce.error = SPError(errorState: error)
//        switch payStrategy {
//        case .auto:
//            paymentCompletion?(.error, SPError(errorState: error).errorDescription)
//            paymentCompletion = nil
//        case .manual:
//            if payInfo == nil {
//                paymentTokenCompletion?(responce)
//                paymentTokenCompletion = nil
//            } else {
//                paymentCompletion?(.error, SPError(errorState: error).errorDescription)
//                paymentCompletion = nil
//            }
//        }
//        liveCircleManager.closeSDKWindow()
//    }
    
//    func completionPaymentToken(with paymentToken: String? = nil,
//                                paymentTokenId: String? = nil,
//                                tokenExpiration: Int = 0) {
//        let responce = SPaymentTokenResponse(paymentToken: paymentToken,
//                                             paymentTokenId: paymentTokenId,
//                                             tokenExpiration: tokenExpiration,
//                                             error: nil)
//        paymentTokenCompletion?(responce)
//        paymentTokenCompletion = nil
//        liveCircleManager.closeSDKWindow()
//    }
//
    private func isNewStart(check authInfo: AuthInfo) -> Bool {
        // Проверяем наличие сохраненной информации о запросе
        guard let savedInfo = self.authInfo else { return true }
        // Сравниваем новый запрос с сохраненным
        return authInfo != savedInfo
    }
    
    @objc
    private func closeSdk() {
        completionManager.closeAction()
    }
}
