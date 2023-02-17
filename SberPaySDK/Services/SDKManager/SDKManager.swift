//
//  SDKManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 30.11.2022.
//

import UIKit

struct AuthInfo {
    /// Ключ Kлиента для работы с сервисами платежного шлюза через SDK.
    let apiKey: String
    /// Идентификатора плательщика в вашей системе
    let clientName: String
    /// Сумма операции в минорных единицах
    let orderId: String
    /// clientId
    let clientId: String?
    /// clientId
    let redirectUri: String
}

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
    var paymentTokenRequest: SBPaymentTokenRequest? { get }
    var newStart: Bool { get }
    var payStrategy: PayStrategy { get }
    var authInfo: AuthInfo? { get }
    func config(paymentTokenRequest: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion)
    func configWithOrderId(paymentRequest: SBFullPaymentRequest,
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
    private(set) var paymentTokenRequest: SBPaymentTokenRequest?
    private(set) var fullPaymentRequest: SBFullPaymentRequest?
    private(set) var authInfo: AuthInfo?
    private(set) var payStrategy: PayStrategy = .manual
    private(set) var newStart = true
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func config(paymentTokenRequest: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion) {

       // Проверяем есть ли уже созданный запрос
        if let oldRequest = self.paymentTokenRequest,
           // Сравниваем новый запрос с предидущим
           oldRequest.orderNumber == paymentTokenRequest.orderNumber {
            newStart = false
        } else {
            newStart = true
        }

        payStrategy = .manual
        self.paymentTokenRequest = paymentTokenRequest
        authInfo = AuthInfo(apiKey: paymentTokenRequest.apiKey,
                            clientName: paymentTokenRequest.clientName,
                            orderId: paymentTokenRequest.orderNumber,
                            clientId: paymentTokenRequest.clientId,
                            redirectUri: paymentTokenRequest.redirectUri)
        authManager.apiKey = paymentTokenRequest.apiKey
        self.paymentTokenCompletion = completion
    }
    
    func configWithOrderId(paymentRequest: SBFullPaymentRequest,
                           completion: @escaping PayCompletion) {
        // Проверяем есть ли уже созданный запрос
         if let oldRequest = self.fullPaymentRequest,
            // Сравниваем новый запрос с предидущим
            oldRequest.orderId == paymentRequest.orderId {
             newStart = false
         } else {
             newStart = true
         }
        payStrategy = .auto
        fullPaymentRequest = paymentRequest
        authInfo = AuthInfo(apiKey: paymentRequest.apiKey,
                            clientName: paymentRequest.clientName,
                            orderId: paymentRequest.orderId,
                            clientId: paymentRequest.clientId,
                            redirectUri: paymentRequest.redirectUri)
        authManager.apiKey = paymentRequest.apiKey
        self.paymentCompletion = completion
    }
    
    func completionWithError(error: SDKError) {
        let responce = SBPaymentTokenResponse()
        responce.error = SBPError(errorState: error)
        switch payStrategy {
        case .auto:
            paymentCompletion?(SBPError(errorState: error))
            paymentCompletion = nil
        case .manual:
            paymentTokenCompletion?(responce)
            paymentTokenCompletion = nil
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
}
