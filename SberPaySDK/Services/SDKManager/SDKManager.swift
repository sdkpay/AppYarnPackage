//
//  SDKManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 30.11.2022.
//

import UIKit

enum PayStrategy {
    case auto
    case manual
}

typealias PayCompletion = (SBPError?) -> Void

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
    var payHandler: Action? { get set }
    func config(paymentTokenRequest: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion)
    func configWithOrderId(paymentRequest: SBFullPaymentRequest,
                           completion: @escaping PayCompletion)
    func pay(with paymentRequest: SBPaymentRequest,
             completion: @escaping PayCompletion)
    func completionPaymentToken(with paymentToken: String?,
                                paymentTokenId: String?,
                                tokenExpiration: Int)
    func completionWithError(error: SDKError)
    func completionPay(with error: SDKError?)
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

    private var paymentCompletion: PayCompletion?
    private var paymentTokenCompletion: PaymentTokenCompletion?

    private(set) var authInfo: AuthInfo?
    private(set) var payInfo: PayInfo?
    
    var payHandler: Action?

    private(set) var payStrategy: PayStrategy = .manual
    private(set) var newStart = true
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func config(paymentTokenRequest: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion) {
        newStart = isNewStart(orderId: paymentTokenRequest.orderNumber)
        payStrategy = .manual
        authInfo = AuthInfo(paymentTokenRequest: paymentTokenRequest)
        authManager.apiKey = paymentTokenRequest.apiKey
        authManager.lang = paymentTokenRequest.language
        self.paymentTokenCompletion = completion
    }
    
    func configWithOrderId(paymentRequest: SBFullPaymentRequest,
                           completion: @escaping PayCompletion) {
        newStart = isNewStart(orderId: paymentRequest.orderId)
        payStrategy = .auto
        authInfo = AuthInfo(fullPaymentRequest: paymentRequest)
        authManager.apiKey = paymentRequest.apiKey
        authManager.lang = paymentRequest.language
        self.paymentCompletion = completion
    }
    
    func pay(with paymentRequest: SBPaymentRequest,
             completion: @escaping PayCompletion) {
        payInfo = PayInfo(paymentRequest: paymentRequest)
        paymentCompletion = completion
        payHandler?()
    }
    
    func completionWithError(error: SDKError) {
        let responce = SBPaymentTokenResponse()
        responce.error = SBPError(errorState: error)
        switch payStrategy {
        case .auto:
            paymentCompletion?(SBPError(errorState: error))
            paymentCompletion = nil
        case .manual:
            if payInfo == nil {
                paymentTokenCompletion?(responce)
                paymentTokenCompletion = nil
            } else {
                paymentCompletion?(SBPError(errorState: error))
                paymentCompletion = nil
            }
        }
    }
    
    func completionPaymentToken(with paymentToken: String? = nil,
                                paymentTokenId: String? = nil,
                                tokenExpiration: Int = 0) {
        let responce = SBPaymentTokenResponse(paymentToken: paymentToken,
                                              paymentTokenId: paymentTokenId,
                                              tokenExpiration: tokenExpiration,
                                              error: nil)
        paymentTokenCompletion?(responce)
    }
    
    func completionPay(with error: SDKError? = nil) {
        if let error = error {
            paymentCompletion?(SBPError(errorState: error))
        } else {
            paymentCompletion?(nil)
        }
        paymentCompletion = nil
    }
    
    private func isNewStart(orderId: String) -> Bool {
        // Проверяем есть ли уже созданный запрос
         if let authInfo = self.authInfo,
            // Сравниваем новый запрос с предидущим
            authInfo.orderId == orderId {
             return false
         } else {
             return true
         }
    }
}
