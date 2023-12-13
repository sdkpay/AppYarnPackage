//
//  CompletionManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.09.2023.
//

import UIKit

final class CompletionManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: CompletionManager = DefaultCompletionManager(liveCircleManager: container.resolve())
        container.register(service: service)
    }
}

protocol CompletionManager {
    func setPaymentCompletion(_ completion: @escaping PaymentCompletion)
    func setPaymentTokenCompletion(_ completion: @escaping PaymentTokenCompletion)
    func completePay(with state: SPayState)
    func completePaymentToken(with paymentToken: String?,
                              paymentTokenId: String?,
                              tokenExpiration: Int)
    func completeWithError(_ error: SDKError)
    func closeAction()
    func dismissCloseAction(_ view: ContentVC?)
}

extension CompletionManager {
    func completePaymentToken(with paymentToken: String? = nil,
                              paymentTokenId: String? = nil,
                              tokenExpiration: Int = 0) {
        completePaymentToken(with: paymentToken, paymentTokenId: paymentTokenId, tokenExpiration: tokenExpiration)
    }
}

final class DefaultCompletionManager: CompletionManager {
    
    private let liveCircleManager: LiveCircleManager
    
    private var paymentCompletion: PaymentCompletion?
    private var paymentTokenCompletion: PaymentTokenCompletion?
    
    private var payResponse: PaymentResponse?
    private var paymentTokenResponse: PaymentTokenResponse?
    private var error: SPError?
    
    private var closeActionInProgress = false
    
    init(liveCircleManager: LiveCircleManager) {
        self.liveCircleManager = liveCircleManager
    }
    
    func setPaymentCompletion(_ completion: @escaping PaymentCompletion) {
        paymentCompletion = completion
    }
    
    func setPaymentTokenCompletion(_ completion: @escaping PaymentTokenCompletion) {
        paymentTokenCompletion = completion
    }
    
    func completePay(with state: SPayState) {
        switch state {
        case .success:
            payResponse = (state: state, info: Strings.Alert.Pay.Success.title)
        case .waiting:
            payResponse = (state: state, info: ConfigGlobal.localization?.payLoading ?? "")
        default:
            assertionFailure("Необходимо передавать только успешные сценарии оплаты")
        }
    }
    
    func completePaymentToken(with paymentToken: String?,
                              paymentTokenId: String?,
                              tokenExpiration: Int = 0) {
        let model = SPaymentTokenResponseModel(paymentToken: paymentToken,
                                               paymentTokenId: paymentTokenId,
                                               tokenExpiration: tokenExpiration)
        
        paymentTokenResponse = (state: .success, info: model)
        giveActualCompletion()
    }
    
    func completeWithError(_ error: SDKError) {
        self.error = SPError(errorState: error)
    }
    
    func closeAction() {
        giveActualCompletion()
    }
    
    func dismissCloseAction(_ view: ContentVC?) {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.giveActualCompletion()
        })
    }
    
    private func giveActualCompletion() {
        
        if paymentTokenCompletion != nil {
            giveTokenCompletion()
        } else if paymentCompletion != nil {
            givePayCompletion()
        }
    }
    
    private func givePayCompletion() {
        if let payResponse {
            paymentCompletion?(payResponse)
        } else if let error {
            let response = PaymentResponse((state: .error, info: error.errorDescription))
            paymentCompletion?(response)
        } else {
            let response = PaymentResponse((state: .cancel, info: Strings.Error.close))
            paymentCompletion?(response)
        }
        error = nil
        payResponse = nil
        paymentTokenResponse = nil
        paymentCompletion = nil
        closeActionInProgress = false
        liveCircleManager.closeSDKWindow()
    }
    
    private func giveTokenCompletion() {
        if let paymentTokenResponse {
            paymentTokenCompletion?(paymentTokenResponse)
        } else if let error {
            let response = PaymentTokenResponse((state: .error, info: SPaymentTokenResponseModel(error: error.errorDescription)))
            paymentTokenCompletion?(response)
        } else {
            let response = PaymentTokenResponse((state: .cancel, info: SPaymentTokenResponseModel(error: Strings.Error.close)))
            paymentTokenCompletion?(response)
        }
        paymentTokenCompletion = nil
        closeActionInProgress = false
        liveCircleManager.closeSDKWindow()
    }
}
