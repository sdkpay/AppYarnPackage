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
    func setup(apiKey: String, bnplPlan: Bool, environment: SEnvironment, completion: Action?)
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
    func debugConfig(network: NetworkState, ssl: Bool)
}

extension SBPayService {
    func setup(apiKey: String,
               bnplPlan: Bool = true,
               environment: SEnvironment = .prod,
               completion: Action? = nil) {
        setup(apiKey: apiKey,
              bnplPlan: bnplPlan,
              environment: environment,
              completion: completion)
    }
}

final class DefaultSBPayService: SBPayService {
    private lazy var startService: StartupService = DefaultStartupService(timeManager: timeManager)
    private lazy var locator: LocatorService = DefaultLocatorService()
    private lazy var buildSettings: BuildSettings = DefaultBuildSettings()
    private let assemblyManager = AssemblyManager()
    private let timeManager = OptimizationCheсkerManager()
    private var apiKey: String?
    
    func setup(apiKey: String,
               bnplPlan: Bool,
               environment: SEnvironment,
               completion: Action? = nil) {
        self.apiKey = apiKey
        UIFont.registerFontsIfNeeded()
        locator.register(service: buildSettings)
        assemblyManager.registerServices(to: locator)
        locator
            .resolve(EnvironmentManager.self)
            .setEnvironment(environment)
        locator
            .resolve(PartPayService.self)
            .setUserEnableBnpl(bnplPlan, enabledLevel: .merch)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        SBLogger.dateString = dateFormatter.string(from: Date())
        locator
            .resolve(RemoteConfigService.self)
            .getConfig(with: apiKey) { error in
                completion?()
                guard error == nil else { return }
                self.locator
                    .resolve(AnalyticsService.self)
                    .config()
            }
    }
    
    var isReadyForSPay: Bool {
        SBLogger.log(.version)
        // Для симулятора всегда true для удобства разработки
#if targetEnvironment(simulator)
        return true
#else
        
        let target = locator.resolve(EnvironmentManager.self).environment == .sandboxWithoutBankApp
        if target {
            return true
        } else {
            let apps = locator.resolve(BankAppManager.self).avaliableBanks
            locator
                .resolve(AnalyticsService.self)
                .sendEvent(apps.isEmpty ? .NoBankAppFound : .BankAppFound)
            SBLogger.log("🏦 Found bank apps: \n\(apps.map({ $0.name }))")
            return !apps.isEmpty
        }
#endif
    }
    
    func getPaymentToken(with viewController: UIViewController,
                         with request: SPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion) {
        SBLogger.logRequestPaymentToken(with: request)
        guard let apiKey = apiKey else { return assertionFailure(Strings.Merchant.Alert.apikey) }
        locator
            .resolve(SDKManager.self)
            .config(apiKey: apiKey,
                    paymentTokenRequest: request,
                    completion: { response in
                SBLogger.logResponsePaymentToken(with: response)
                completion(response)
            })
        startService.openInitialScreen(with: viewController, with: locator)
    }
    
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion) {
        locator
            .resolve(SDKManager.self)
            .pay(with: paymentRequest, completion: completion)
    }
    
    func completePayment(paymentSuccess: SPayState,
                         completion: @escaping Action) {
        startService.completePayment(paymentSuccess: paymentSuccess, completion: completion)
    }
    
    func payWithOrderId(with viewController: UIViewController,
                        paymentRequest: SFullPaymentRequest,
                        completion: @escaping PaymentCompletion) {
        timeManager.startCheckingCPULoad()
        timeManager.startContectionTypeChecking()
        guard let apiKey = apiKey else { return assertionFailure(Strings.Merchant.Alert.version) }
        locator
            .resolve(SDKManager.self)
            .configWithOrderId(apiKey: apiKey,
                               paymentRequest: paymentRequest,
                               completion: completion)
        startService.openInitialScreen(with: viewController,
                                       with: locator)
        timeManager.stopCheckingCPULoad {
            self.locator
                .resolve(AnalyticsService.self)
                .sendEvent(.StartTime, with: [$0])
        }
    }
    
    func getResponseFrom(_ url: URL) {
        locator
            .resolve(AuthService.self)
            .completeAuth(with: url)
    }
    
    func debugConfig(network: NetworkState, ssl: Bool) {
        buildSettings.setConfig(networkState: network, ssl: ssl)
    }
}
