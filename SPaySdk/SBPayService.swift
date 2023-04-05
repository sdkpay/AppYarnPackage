//
//  SBPayService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 15.11.2022.
//

import UIKit

typealias PaymentTokenCompletion = (SPaymentTokenResponse) -> Void
typealias PaymentCompletion = (_ state: SPayState, _ info: String) -> Void

protocol SBPayService {
    func setup(apiKey: String, completion: Action?)
    var isReadyForSPay: Bool { get }
    func getPaymentToken(with viewController: UIViewController,
                         with request: SPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion)
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion)
    func payWithOrderId(with viewController: UIViewController,
                        paymentRequest: SFullPaymentRequest,
                        completion: @escaping PaymentCompletion)
    func completePayment(paymentSuccess: SPayState,
                         completion: @escaping Action)
    func getResponseFrom(_ url: URL)
}

extension SBPayService {
    func setup(apiKey: String, completion: Action? = nil) {
        setup(apiKey: apiKey, completion: completion)
    }
}

final class DefaultSBPayService: SBPayService {

    private lazy var startService: StartupService = DefaultStartupService(timeManager: timeManager)
    private lazy var locator: LocatorService = DefaultLocatorService()
    private var apiKey: String?
    private let timeManager = OptimizationCheсkerManager()

    private var assemblies: [Assembly] = [
        AnalyticsServiceAssembly(),
        PersonalMetricsServiceAssembly(),
        AuthManagerAssembly(),
        BaseRequestManagerAssembly(),
        NetworkServiceAssembly(),
        RemoteConfigServiceAssembly(),
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
    
    func setup(apiKey: String, completion: Action? = nil) {
        self.apiKey = apiKey
        UIFont.registerFontsIfNeeded()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        SBLogger.dateString = dateFormatter.string(from: Date())
        registerServices()
        let remoteConfigService: RemoteConfigService = locator.resolve()
        remoteConfigService.getConfig(with: apiKey) { error in
            completion?()
            guard error == nil else { return }
            let analyticsService: AnalyticsService = self.locator.resolve()
            analyticsService.config()
        }
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
                         with request: SPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion) {
        SBLogger.logRequestPaymentToken(with: request)
        let manager: SDKManager = locator.resolve()
        guard let apiKey = apiKey else { return assertionFailure(.MerchantAlert.alertApiKey) }
        manager.config(apiKey: apiKey,
                       paymentTokenRequest: request,
                       completion: { response in
            SBLogger.logResponsePaymentToken(with: response)
            completion(response)
        })
        startService.openInitialScreen(with: viewController, with: locator)
        SBLogger.log("📃 Network state - \(BuildSettings.shared.networkState.rawValue)")
    }
    
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion) {
        let manager: SDKManager = locator.resolve()
        manager.pay(with: paymentRequest, completion: completion)
    }
    
    func completePayment(paymentSuccess: SPayState,
                         completion: @escaping Action) {
        startService.completePayment(paymentSuccess: paymentSuccess, completion: completion)
    }
    
    func payWithOrderId(with viewController: UIViewController,
                        paymentRequest: SFullPaymentRequest,
                        completion: @escaping PaymentCompletion) {
        let manager: SDKManager = locator.resolve()
        timeManager.startCheckingCPULoad()
        timeManager.startContectionTypeChecking()
        guard let apiKey = apiKey else { return assertionFailure(.MerchantAlert.alertVersion) }
        manager.configWithOrderId(apiKey: apiKey,
                                  paymentRequest: paymentRequest,
                                  completion: completion)
        SBLogger.log("📃 Network state - \(BuildSettings.shared.networkState.rawValue)")
        startService.openInitialScreen(with: viewController,
                                       with: locator)
        timeManager.stopCheckingCPULoad {
            let analyticsService: AnalyticsService = self.locator.resolve()
            analyticsService.sendEvent(.StartTime, with: [$0])
        }
    }

    func getResponseFrom(_ url: URL) {
        let authService: AuthService = locator.resolve()
        authService.completeAuth(with: url)
    }
}
