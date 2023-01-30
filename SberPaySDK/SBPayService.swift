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
    
    private lazy var network: NetworkService = {
       DefaultNetworkService(provider: BuildSettings.needStubs ? StubNetworkProvider(delayedSeconds: 2) : DefaultNetworkProvider())
    }()

    private lazy var manager: SDKManager = DefaultSDKManager()
    private lazy var authManager: AuthManager = DefaultAuthManager()
    private lazy var authService: AuthService = DefaultAuthService(network: network,
                                                                   sdkManager: manager,
                                                                   analytics: analyticsService,
                                                                   authManager: authManager)

    private lazy var userService: UserService = DefaultUserService(network: network,
                                                                   sdkManager: manager,
                                                                   authManager: authManager)
    private lazy var personalMetricsService: PersonalMetricsService = DefaultPersonalMetricsService()

    private lazy var locator: LocatorService = {
        let service = DefaultLocatorService()
        service.register(service: analyticsService)
        service.register(service: startService)
        service.register(service: authService)
        service.register(service: network)
        service.register(service: userService)
        service.register(service: manager)
        service.register(service: personalMetricsService)
        service.register(service: authManager)
        return service
    }()
    
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
        manager.config(paymentTokenRequest: request, completion: { response in
            SBLogger.logResponsePaymentToken(with: response)
            completion(response)
        })
        SBLogger.log("📃 Stubs enabled - \(BuildSettings.needStubs)")
        startService.openInitialScreen(with: manager, locator: locator, analytics: analyticsService)
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
