//
//  SBPayService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 15.11.2022.
//

import UIKit
import DynatraceStatic

typealias PaymentTokenCompletion = (SBPaymentTokenResponse) -> Void

protocol SBPayService {
    var isReadyForSberPay: Bool { get }
    func getPaymentToken(with request: SBPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion)
    func pay(with paymentRequest: SBPaymentRequest,
             completion: @escaping (_ error: SBPError?) -> Void)
    func completePayment(paymentSuccess: Bool,
                         completion: () -> Void)
    func getResponseFrom(_ url: URL)
}

final class DefaultSBPayService: SBPayService {
    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService()
    private lazy var startService: StartupService = DefaultStartupService()
    private lazy var network: NetworkService = DefaultNetworkService(provider: DefaultNetworkProvider())
    private lazy var authService: AuthService = DefaultAuthService(analytics: analyticsService)
    private lazy var manager: SDKManager = DefaultSDKManager(networkService: network, authService: authService, analytics: analyticsService)
    private lazy var personalMetricsService: PersonalMetricsService = DefaultPersonalMetricsService()
    
    var isReadyForSberPay: Bool {
        // Для симулятора всегда true для удобства разработки
            #if targetEnvironment(simulator)
       true
            #else
        let apps = authService.avaliableBanks
        SBLogger.log("🏦 Found bank apps: \n\(authService.avaliableBanks)")
        analyticsService.sendEvent(apps.isEmpty ? .NoBankAppFound : .BankAppFound)
        return !apps.isEmpty
            #endif
    }

    func getPaymentToken(with request: SBPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion) {
        SBLogger.logRequestPaymentToken(with: request)
        manager.config(request: request, completion: { response in
            SBLogger.logResponsePaymentToken(with: response)
            completion(response)
        })
        startService.openInitialScreen(with: manager, analytics: analyticsService)
        print(personalMetricsService.getUserData(completion: { result in
            guard let result = result else { return }
            SBLogger.log(.biZone + result)
        }))
    }
    
    func pay(with paymentRequest: SBPaymentRequest,
             completion: @escaping (_ error: SBPError?) -> Void) {
    }
    
    func completePayment(paymentSuccess: Bool,
                         completion: () -> Void) {
    }
    
    func getResponseFrom(_ url: URL) {
        authService.completeAuth(with: url)
    }
}
