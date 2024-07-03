//
//  CompletionManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.09.2023.
//

import UIKit

final class CompletionManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(CompletionManager.self)
    
    func register(in container: LocatorService) {
        let service: CompletionManager = DefaultCompletionManager(liveCircleManager: container.resolve(),
                                                                  localSessionIdService: container.resolve(),
                                                                  analyticsService: container.resolve())
        container.register(service: service)
    }
}

protocol CompletionManager {
    func setPaymentCompletion(_ completion: @escaping PaymentCompletion)
    func completePay(with state: SPayState)
    func completeWithError(_ error: SDKError)
    func closeAction()
    func dismissCloseAction(_ view: ContentVC?)
}

final class DefaultCompletionManager: CompletionManager {
    
    private let liveCircleManager: LiveCircleManager
    private let analyticsService: AnalyticsService
    private let localSessionIdService: LocalSessionIdentifierService
    
    private var paymentCompletion: PaymentCompletion?
    
    private var payResponse: PaymentResponse?
    private var error: SPError?
    
    private var closeActionInProgress = false
    
    init(liveCircleManager: LiveCircleManager,
         localSessionIdService: LocalSessionIdentifierService,
         analyticsService: AnalyticsService) {
        self.liveCircleManager = liveCircleManager
        self.analyticsService = analyticsService
        self.localSessionIdService = localSessionIdService
    }

    func setPaymentCompletion(_ completion: @escaping PaymentCompletion) {
        paymentCompletion = completion
    }
    
    func completePay(with state: SPayState) {
        switch state {
        case .success:
            payResponse = (state: state, 
                           info: Strings.Alert.Pay.Success.title, 
                           localSessionId: localSessionIdService.localSessionIdentifier)
        case .waiting:
            payResponse = (state: state,
                           info: ConfigGlobal.localization?.payLoading ?? "",
                           localSessionId: localSessionIdService.localSessionIdentifier)
        default:
            assertionFailure("Необходимо передавать только успешные сценарии оплаты")
        }
    }

    func completeWithError(_ error: SDKError) {
        
        self.error = SPError(errorState: error)
    }
    
    func closeAction() {
        
        giveActualCompletion()
    }
    
    func dismissCloseAction(_ view: ContentVC?) {

        DispatchQueue.main.async {
            self.liveCircleManager.rootController?.dismiss(animated: true,
                                                           completion: { [weak self] in
                self?.giveActualCompletion()
            })
        }
    }
    
    private func giveActualCompletion() {
        
        analyticsService.finishSession()
        
        Task {
            await givePayCompletion()
        }
    }
    
    @MainActor
    private func givePayCompletion() async {
        await liveCircleManager.closeSDKWindow()
        
        if let payResponse {
            paymentCompletion?(payResponse)
        } else if let error {
            let response = PaymentResponse((state: .error, 
                                            info: error.errorDescription,
                                            localSessionId: localSessionIdService.localSessionIdentifier
                                           ))
            paymentCompletion?(response)
        } else {
            let response = PaymentResponse((state: .cancel, 
                                            info: Strings.Error.close,
                                            localSessionId: localSessionIdService.localSessionIdentifier
                                           ))
            paymentCompletion?(response)
        }
        error = nil
        payResponse = nil
        paymentCompletion = nil
    }
}
