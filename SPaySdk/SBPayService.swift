//
//  SBPayService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 15.11.2022.
//

import UIKit

typealias PaymentTokenCompletion = (SBPaymentTokenResponse) -> Void
typealias PaymentCompletion = (_ state: SBPayState, _ info: String) -> Void

protocol SBPayService {
    func setup()
    var isReadyForSPay: Bool { get }
    func getPaymentToken(with viewController: UIViewController,
                         with request: SBPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion)
    func pay(with paymentRequest: SBPaymentRequest,
             completion: @escaping PaymentCompletion)
    func payWithOrderId(with viewController: UIViewController,
                        paymentRequest: SBFullPaymentRequest,
                        completion: @escaping PaymentCompletion)
    func completePayment(paymentSuccess: SBPayState,
                         completion: @escaping Action)
    func getResponseFrom(_ url: URL)
}

final class DefaultSBPayService: SBPayService {
    
    private lazy var startService: StartupService = DefaultStartupService()
    private lazy var locator: LocatorService = DefaultLocatorService()

    private var assemblies: [Assembly] = [
        AnalyticsServiceAssembly(),
        PersonalMetricsServiceAssembly(),
        AuthManagerAssembly(),
        BaseRequestManagerAssembly(),
        NetworkServiceAssembly(),
        AlertServiceAssembly(),
        SDKManagerAssembly(),
        AuthServiceAssembly(),
        UserServiceAssembly(),
        LocationManagerAssembly(),
        PaymentServiceAssembly()
    ]
    
    private func registerServices() {
        for assembly in assemblies {
            assembly.register(in: locator)
        }
    }
    
    func setup() {
        UIFont.registerFontsIfNeeded()
    }
    
    var isReadyForSPay: Bool {
        SBLogger.log(.version)
        registerServices()
        // Для симулятора всегда true для удобства разработки
            #if targetEnvironment(simulator)
       return true
            #else
        let authService: AuthService = locator.resolve()
        let analyticsService: AnalyticsService = locator.resolve()
        let apps = authService.avaliableBanks
        SBLogger.log("🏦 Found bank apps: \n\(authService.avaliableBanks)")
        analyticsService.sendEvent(apps.isEmpty ? .NoBankAppFound : .BankAppFound)
        return !apps.isEmpty
            #endif
    }

    func getPaymentToken(with viewController: UIViewController,
                         with request: SBPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion) {
        SBLogger.logRequestPaymentToken(with: request)
        let manager: SDKManager = locator.resolve()
        manager.config(paymentTokenRequest: request, completion: { response in
            SBLogger.logResponsePaymentToken(with: response)
            completion(response)
        })
        startService.openInitialScreen(with: viewController, with: locator)
        SBLogger.log("📃 Network state - \(BuildSettings.shared.networkState.rawValue)")
    }
    
    func pay(with paymentRequest: SBPaymentRequest,
             completion: @escaping PaymentCompletion) {
        let manager: SDKManager = locator.resolve()
        manager.pay(with: paymentRequest, completion: completion)
    }
    
    func completePayment(paymentSuccess: SBPayState,
                         completion: @escaping Action) {
        startService.completePayment(paymentSuccess: paymentSuccess, completion: completion)
    }
    
    func payWithOrderId(with viewController: UIViewController,
                        paymentRequest: SBFullPaymentRequest,
                        completion: @escaping PaymentCompletion) {
        let manager: SDKManager = locator.resolve()
        manager.configWithOrderId(paymentRequest: paymentRequest,
                                  completion: completion)
        SBLogger.log("📃 Network state - \(BuildSettings.shared.networkState.rawValue)")
        startService.openInitialScreen(with: viewController,
                                       with: locator)
    }

    func getResponseFrom(_ url: URL) {
        let authService: AuthService = locator.resolve()
        authService.completeAuth(with: url)
    }
}
