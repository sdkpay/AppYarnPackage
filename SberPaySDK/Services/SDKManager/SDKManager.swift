//
//  SDKManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 30.11.2022.
//

import UIKit

final class SDKManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: SDKManager = DefaultSDKManager()
        container.register(service: service)
    }
}

protocol SDKManager {
    var paymentTokenRequest: SBPaymentTokenRequest? { get }
    func config(paymentTokenRequest: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion)
    func completionPaymentToken(with paymentToken: String?,
                                paymentTokenId: String?,
                                tokenExpiration: Int)
    func completionWithError(error: SDKError)
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
    private var completion: PaymentTokenCompletion?
    private(set) var paymentTokenRequest: SBPaymentTokenRequest?

    func config(paymentTokenRequest: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion) {
        self.paymentTokenRequest = paymentTokenRequest
        self.completion = completion
    }
    
    func completionWithError(error: SDKError) {
        let responce = SBPaymentTokenResponse()
        responce.error = SBPError(errorState: error)
        completion?(responce)
    }
    
    func completionPaymentToken(with paymentToken: String? = nil,
                                paymentTokenId: String? = nil,
                                tokenExpiration: Int = 0) {
        let responce = SBPaymentTokenResponse(paymentToken: paymentToken,
                                              paymentTokenId: paymentTokenId,
                                              tokenExpiration: tokenExpiration,
                                              error: nil)
        completion?(responce)
    }
}
