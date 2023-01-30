//
//  SDKManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 30.11.2022.
//

import UIKit

protocol SDKManager {
    var paymentTokenRequest: SBPaymentTokenRequest? { get }
    func config(paymentTokenRequest: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion)
    func completionWithError(error: SDKError)
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
}
