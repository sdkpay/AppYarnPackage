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
    private lazy var startService: StartupService = DefaultStartupService()
    private lazy var locator: LocatorService = DefaultLocatorService()

    private var assemblies: [Assembly] = [
        AnalyticsServiceAssembly(),
        PersonalMetricsServiceAssembly(),
        NetworkServiceAssembly(),
        AuthManagerAssembly(),
        SDKManagerAssembly(),
        AuthServiceAssembly(),
        UserServiceAssembly(),
        LocationManagerAssembly()
    ]
    
    private func registerServices() {
        for assembly in assemblies {
            assembly.register(in: locator)
        }
    }
    
    var isReadyForSberPay: Bool {
        registerServices()
        // Для симулятора всегда true для удобства разработки
            #if targetEnvironment(simulator)
       true
            #else
        let authService: AuthService = locator.resolve()
        let analyticsService: AnalyticsService = locator.resolve()
        let apps = authService.avaliableBanks
        SBLogger.log("🏦 Found bank apps: \n\(authService.avaliableBanks)")
        analyticsService.sendEvent(apps.isEmpty ? .NoBankAppFound : .BankAppFound)
        return !apps.isEmpty
            #endif
    }

    func getPaymentToken(with request: SBPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion) {
        SBLogger.logRequestPaymentToken(with: request)
        let manager: SDKManager = locator.resolve()
        manager.config(paymentTokenRequest: request, completion: { response in
            SBLogger.logResponsePaymentToken(with: response)
            completion(response)
        })
        SBLogger.log("📃 Stubs enabled - \(BuildSettings.needStubs)")
        startService.openInitialScreen(with: locator)
    }
    
    func pay(with paymentRequest: SBPaymentRequest,
             completion: @escaping (_ error: SBPError?) -> Void) {
    }
    
    func completePayment(paymentSuccess: Bool,
                         completion: () -> Void) {
    }
    
    func getResponseFrom(_ url: URL) {
        let authService: AuthService = locator.resolve()
        authService.completeAuth(with: url)
    }
}
