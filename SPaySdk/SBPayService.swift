//
//  SBPayService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 15.11.2022.
//

import UIKit

typealias PaymentTokenResponse = (state: SPayTokenState, info: SPaymentTokenResponseModel)
typealias PaymentTokenCompletion = (PaymentTokenResponse) -> Void
typealias PaymentResponse = (state: SPayState, info: String)
typealias PaymentCompletion = (PaymentResponse) -> Void

protocol SBPayService {
    func setup(bnplPlan: Bool,
               resultViewNeeded: Bool,
               helpers: Bool,
               needLogs: Bool,
               config: SBHelperConfig,
               environment: SEnvironment,
               completion: ((SPError?) -> Void)?)
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion)
    func payWithoutRefresh(with viewController: UIViewController,
                           paymentRequest: SBankInvoicePaymentRequest,
                           completion: @escaping PaymentCompletion)
    func payWithBankInvoiceId(with viewController: UIViewController,
                              paymentRequest: SBankInvoicePaymentRequest,
                              completion: @escaping PaymentCompletion)
    func payWithPartPay(with viewController: UIViewController,
                        paymentRequest: SBankInvoicePaymentRequest,
                        completion: @escaping PaymentCompletion)
    func setBankScheme(_ url: URL) throws
    func getResponseFrom(_ url: URL)
    func debugConfig(network: NetworkState, ssl: Bool, refresh: Bool, debugLogLevel: [DebugLogLevel])
}

final class DefaultSBPayService: SBPayService {

    private lazy var liveCircleManager: LiveCircleManager = DefaultLiveCircleManager(timeManager: timeManager)
    private lazy var locator: LocatorService = DefaultLocatorService()
    private lazy var buildSettings: BuildSettings = DefaultBuildSettings()
    private lazy var logService: LogService = DefaultLogService()
    private lazy var inProgress = false
    private let assemblyManager = AssemblyManager()
    private let timeManager = OptimizationCheсkerManager()
    private var apiKey: String?
    
    func setup(bnplPlan: Bool,
               resultViewNeeded: Bool,
               helpers: Bool,
               needLogs: Bool,
               config: SBHelperConfig,
               environment: SEnvironment,
               completion: ((SPError?) -> Void)?) {
        SBLogger.dateString = Date().readable
        
        FontFamily.registerAllCustomFonts()
        locator.register(service: liveCircleManager)
        locator.register(service: logService)
        locator.register(service: buildSettings)
        
        assemblyManager.registerStartServices(to: locator)
        locator
            .resolve(SetupManager.self)
            .resultViewNeeded(resultViewNeeded)
        locator
            .resolve(LogService.self)
            .setLogsWritable(environment: environment)
        locator
            .resolve(EnvironmentManager.self)
            .setEnvironment(environment)
        locator
            .resolve(AuthManager.self)
            .setEnabledBnpl(bnplPlan)
        locator
            .resolve(HelperConfigManager.self)
            .setConfig(config)
        locator
            .resolve(HelperConfigManager.self)
            .setHelpersNeeded(helpers)
        locator
            .resolve(AnalyticsManager.self)
            .send(EventBuilder()
                    .with(base: .MA)
                    .with(action: .Init)
                    .build(),
                  on: .None,
                  values: [.Environment: "\(environment.rawValue)"])
        
        Task(priority: .medium) {
            
            locator
                .resolve(AnalyticsService.self)
                .config()
            DispatchQueue.main.async {
                completion?(nil)
            }
        }
    }

    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion) {
        locator
            .resolve(SDKManager.self)
            .pay(with: paymentRequest, completion: completion)
    }
    
    func payWithBankInvoiceId(with viewController: UIViewController,
                              paymentRequest: SBankInvoicePaymentRequest,
                              completion: @escaping PaymentCompletion) {
        assemblyManager.registerSessionServices(to: locator)
        guard !inProgress else { return }
        inProgress = true
        timeManager.startCheckingCPULoad()
        timeManager.startContectionTypeChecking()
        
        locator
            .resolve(AnalyticsManager.self)
            .send(EventBuilder()
                .with(base: .MA)
                .with(value: MetricsValue(rawValue: #function.removeArgs))
                .build(),
                  on: .None)
        
        apiKey = paymentRequest.apiKey
        guard let apiKey = apiKey else { return assertionFailure(Strings.MerchantAlert.apikey) }
        if let error = MerchParamsValidator.validateSBankInvoicePaymentRequest(paymentRequest) {
            let response = PaymentResponse(SPayState.error, error)
            completion(response)
        }
        locator
            .resolve(SDKManager.self)
            .configWithBankInvoiceId(apiKey: apiKey,
                                     paymentRequest: paymentRequest) { response in
                self.inProgress = false
                completion(response)
            }
        liveCircleManager.openInitialScreen(with: viewController,
                                            with: locator)
        locator
            .resolve(AnalyticsManager.self)
            .send(EventBuilder()
                .with(base: .MAC)
                .with(value: MetricsValue(rawValue: #function.removeArgs))
                .build(),
                  on: .None)
    }
    
    func payWithoutRefresh(with viewController: UIViewController, 
                           paymentRequest: SBankInvoicePaymentRequest,
                           completion: @escaping PaymentCompletion) {
        assemblyManager.registerSessionServices(to: locator)
        guard !inProgress else { return }
        inProgress = true
        timeManager.startCheckingCPULoad()
        timeManager.startContectionTypeChecking()
        
        locator
            .resolve(AnalyticsManager.self)
            .send(EventBuilder()
                .with(base: .MA)
                .with(value: MetricsValue(rawValue: #function.removeArgs))
                .build(),
                  on: .None)
        
        apiKey = paymentRequest.apiKey
        guard let apiKey = apiKey else { return assertionFailure(Strings.MerchantAlert.apikey) }
        if let error = MerchParamsValidator.validateSBankInvoicePaymentRequest(paymentRequest) {
            let response = PaymentResponse(SPayState.error, error)
            completion(response)
        }
        locator
            .resolve(SDKManager.self)
            .configWithoutRefresh(apiKey: apiKey,
                                  paymentRequest: paymentRequest) { response in
                self.inProgress = false
                completion(response)
            }
        liveCircleManager.openInitialScreen(with: viewController,
                                            with: locator)
        locator
            .resolve(AnalyticsManager.self)
            .send(EventBuilder()
                .with(base: .MAC)
                .with(value: MetricsValue(rawValue: #function.removeArgs))
                .build(),
                  on: .None)
    }
    
    func payWithPartPay(with viewController: UIViewController,
                        paymentRequest: SBankInvoicePaymentRequest,
                        completion: @escaping PaymentCompletion) {
        assemblyManager.registerSessionServices(to: locator)
        guard !inProgress else { return }
        inProgress = true
        timeManager.startCheckingCPULoad()
        timeManager.startContectionTypeChecking()
        
        locator
            .resolve(AnalyticsManager.self)
            .send(EventBuilder()
                .with(base: .MA)
                .with(value: MetricsValue(rawValue: #function.removeArgs))
                .build(),
                  on: .None)
        
        apiKey = paymentRequest.apiKey
        guard let apiKey = apiKey else { return assertionFailure(Strings.MerchantAlert.apikey) }
        if let error = MerchParamsValidator.validateSBankInvoicePaymentRequest(paymentRequest) {
            let response = PaymentResponse(SPayState.error, error)
            completion(response)
        }
        locator
            .resolve(SDKManager.self)
            .configPartPay(apiKey: apiKey,
                           paymentRequest: paymentRequest) { response in
                self.inProgress = false
                completion(response)
            }
        
        var partPayService = locator.resolve(PartPayService.self)
        partPayService.bnplplanSelected = true
        
        liveCircleManager.openInitialScreen(with: viewController,
                                            with: locator)
        locator
            .resolve(AnalyticsManager.self)
            .send(EventBuilder()
                .with(base: .MA)
                .with(value: MetricsValue(rawValue: #function.removeArgs))
                .build(),
                  on: .None)
    }
    
    func getResponseFrom(_ url: URL) {
        
        locator
            .resolve(AuthService.self)
            .completeAuth(with: url)
    }
    
    func setBankScheme(_ url: URL) throws {
        
        try locator
            .resolve(BankAppManager.self)
            .setMerchantBank(url)
    }
    
    func debugConfig(network: NetworkState, ssl: Bool, refresh: Bool, debugLogLevel: [DebugLogLevel]) {
        
        buildSettings.setConfig(networkState: network, ssl: ssl, refresh: refresh, debugLogLevel: debugLogLevel)
    }
}
