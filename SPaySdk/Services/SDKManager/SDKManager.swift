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

final class SDKManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: SDKManager = DefaultSDKManager(authManager: container.resolve())
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
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion)
    func completionPaymentToken(with paymentToken: String?,
                                paymentTokenId: String?,
                                tokenExpiration: Int)
    func completionWithError(error: SDKError)
    func completionPay(with state: SPayState)
}

extension SDKManager {
    func completionPaymentToken(with paymentToken: String? = nil,
                                paymentTokenId: String? = nil,
                                tokenExpiration: Int = 0) {
        completionPaymentToken(with: paymentToken,
                               paymentTokenId: paymentTokenId,
                               tokenExpiration: tokenExpiration)
    }
}

final class DefaultSDKManager: SDKManager {
    private var authManager: AuthManager

    private var paymentCompletion: PaymentCompletion?
    private var paymentTokenCompletion: PaymentTokenCompletion?

    private(set) var authInfo: AuthInfo?
    private(set) var payInfo: PayInfo?
    
    var payHandler: ((PayInfo) -> Void)?

    private(set) var payStrategy: PayStrategy = .manual
    private(set) var newStart = true
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
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
        self.paymentTokenCompletion = completion
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
        self.paymentCompletion = completion
    }
    
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion) {
        payInfo = PayInfo(paymentRequest: paymentRequest)
        authInfo?.orderId = paymentRequest.orderId
        paymentCompletion = completion
        payHandler?(PayInfo(paymentRequest: paymentRequest))
    }
    
    func completionWithError(error: SDKError) {
        let responce = SPaymentTokenResponse()
        responce.error = SPError(errorState: error)
        switch payStrategy {
        case .auto:
            paymentCompletion?(.error, SPError(errorState: error).errorDescription)
            paymentCompletion = nil
        case .manual:
            if payInfo == nil {
                paymentTokenCompletion?(responce)
                paymentTokenCompletion = nil
            } else {
                paymentCompletion?(.error, SPError(errorState: error).errorDescription)
                paymentCompletion = nil
            }
        }
        NotificationCenter.default.post(name: Notification.Name(closeSDKNotificationWithError),
                                        object: nil,
                                        userInfo: nil)
    }
    
    func completionPaymentToken(with paymentToken: String? = nil,
                                paymentTokenId: String? = nil,
                                tokenExpiration: Int = 0) {
        let responce = SPaymentTokenResponse(paymentToken: paymentToken,
                                             paymentTokenId: paymentTokenId,
                                             tokenExpiration: tokenExpiration,
                                             error: nil)
        paymentTokenCompletion?(responce)
    }
    
    func completionPay(with state: SPayState) {
        switch state {
        case .success:
            paymentCompletion?(.success, Strings.Alert.Pay.Success.title)
        case .waiting:
            paymentCompletion?(.waiting, Strings.Alert.Pay.No.Waiting.title("банка"))
        case .error:
            paymentCompletion?(.error, Strings.Alert.Error.Main.title)
        }
        paymentCompletion = nil
    }
    
    private func isNewStart(check authInfo: AuthInfo) -> Bool {
        // Проверяем наличие сохраненной информации о запросе
        guard let savedInfo = self.authInfo else { return true }
        // Сравниваем новый запрос с сохраненным
        return authInfo != savedInfo
    }
}
