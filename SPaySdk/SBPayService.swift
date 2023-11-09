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
    func setup(apiKey: String?, bnplPlan: Bool, environment: SEnvironment, completion: Action?)
    var isReadyForSPay: Bool { get }
    func getPaymentToken(with viewController: UIViewController,
                         with request: SPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion)
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion)
    func payWithBankInvoiceId(with viewController: UIViewController,
                              paymentRequest: SBankInvoicePaymentRequest,
                              completion: @escaping PaymentCompletion)
    func completePayment(paymentSuccess: SPayState,
                         completion: @escaping Action)
    func getResponseFrom(_ url: URL)
    func debugConfig(network: NetworkState, ssl: Bool, refresh: Bool)
}

extension SBPayService {
    func setup(apiKey: String?,
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
    private lazy var liveCircleManager: LiveCircleManager = DefaultLiveCircleManager(timeManager: timeManager)
    private lazy var locator: LocatorService = DefaultLocatorService()
    private lazy var keychainStorage: KeychainStorage = DefaultKeychainStorage()
    private lazy var buildSettings: BuildSettings = DefaultBuildSettings()
    private lazy var logService: LogService = DefaultLogService()
    private lazy var inProgress = false
    private let assemblyManager = AssemblyManager()
    private let timeManager = OptimizationCheсkerManager()
    private var apiKey: String?
    
    func setup(apiKey: String?,
               bnplPlan: Bool,
               environment: SEnvironment,
               completion: Action? = nil) {
        self.apiKey = apiKey
        FontFamily.registerAllCustomFonts()
        locator.register(service: keychainStorage)
        locator.register(service: liveCircleManager)
        locator.register(service: logService)
        locator.register(service: buildSettings)
        assemblyManager.registerServices(to: locator)
        locator
            .resolve(LogService.self)
            .setLogsWritable(environment: environment)
        locator
            .resolve(EnvironmentManager.self)
            .setEnvironment(environment)
        locator
            .resolve(PartPayService.self)
            .setEnabledBnpl(bnplPlan, enabledLevel: .merch)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        SBLogger.dateString = dateFormatter.string(from: Date())
        
        Task(priority: .medium) {
            
            do {
                try await locator
                    .resolve(RemoteConfigService.self)
                    .getConfig(with: apiKey)
                locator
                    .resolve(AnalyticsService.self)
                    .config()
            }
        }
    }
    
    var isReadyForSPay: Bool {
        SBLogger.log(.version)
        locator
            .resolve(AnalyticsService.self)
            .sendEvent(.MAIsReadyForSPay)
        let apps = locator.resolve(BankAppManager.self).avaliableBanks
        locator
            .resolve(AnalyticsService.self)
            .sendEvent(apps.isEmpty ? .LCNoBankAppFound : .LCBankAppFound)
        SBLogger.log("🏦 Found bank apps: \n\(apps.map({ $0.name }))")
        let isDeprecated = locator
            .resolve(VersionСontrolManager.self)
            .isVersionDepicated
        return !apps.isEmpty && !isDeprecated
    }
    
    func getPaymentToken(with viewController: UIViewController,
                         with request: SPaymentTokenRequest,
                         completion: @escaping PaymentTokenCompletion) {
        locator
            .resolve(AnalyticsService.self)
            .sendEvent(.MAGetPaymentToken)
        if apiKey == nil {
            apiKey = request.apiKey
        }
        
        guard let apiKey = apiKey else { return assertionFailure(Strings.Merchant.Alert.apikey) }
        locator
            .resolve(SDKManager.self)
            .config(apiKey: apiKey,
                    paymentTokenRequest: request,
                    completion: { response in
                completion(response)
            })
        liveCircleManager.openInitialScreen(with: viewController, with: locator)
        locator
            .resolve(AnalyticsService.self)
            .sendEvent(.MACGetPaymentToken)
    }
    
    func pay(with paymentRequest: SPaymentRequest,
             completion: @escaping PaymentCompletion) {
        locator
            .resolve(AnalyticsService.self)
            .sendEvent(.MAPay)
        locator
            .resolve(SDKManager.self)
            .pay(with: paymentRequest, completion: completion)
        locator
            .resolve(AnalyticsService.self)
            .sendEvent(.MACPay)
    }
    
    func completePayment(paymentSuccess: SPayState,
                         completion: @escaping Action) {
        liveCircleManager.completePayment(paymentSuccess: paymentSuccess, completion: completion)
    }
    
    func payWithBankInvoiceId(with viewController: UIViewController,
                              paymentRequest: SBankInvoicePaymentRequest,
                              completion: @escaping PaymentCompletion) {
        guard !inProgress else { return }
        inProgress = true
        timeManager.startCheckingCPULoad()
        timeManager.startContectionTypeChecking()
        locator
            .resolve(AnalyticsService.self)
            .sendEvent(.MAPayWithBankInvoiceId)
        apiKey = paymentRequest.apiKey
        guard let apiKey = apiKey else { return assertionFailure(Strings.Merchant.Alert.apikey) }
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
            .resolve(AnalyticsService.self)
            .sendEvent(.MACPayWithBankInvoiceId)
    }
    
    func getResponseFrom(_ url: URL) {
        locator
            .resolve(AuthService.self)
            .completeAuth(with: url)
    }
    
    func debugConfig(network: NetworkState, ssl: Bool, refresh: Bool) {
        buildSettings.setConfig(networkState: network, ssl: ssl, refresh: refresh)
    }
}
