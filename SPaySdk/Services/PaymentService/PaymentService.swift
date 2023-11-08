//
//  PaymentService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.02.2023.
//

import Foundation

enum PayError: Error {
    case noInternetConnection
    case timeOut
    case personalInfo
    case partPayError
    case unknownStatus
    case defaultError
}

final class PaymentServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: PaymentService = DefaultPaymentService(authManager: container.resolve(),
                                                                network: container.resolve(), userService: container.resolve(),
                                                                personalMetricsService: container.resolve(),
                                                                completionManager: container.resolve(),
                                                                buildSettings: container.resolve(),
                                                                analytics: container.resolve(),
                                                                sdkManager: container.resolve(),
                                                                parsingErrorAnaliticManager: container.resolve())
            return service
        }
    }
}

protocol PaymentService {
    func tryToPay(paymentId: Int,
                  isBnplEnabled: Bool,
                  completion: @escaping ((Result<Void, PayError>) -> Void))
    func tryToGetPaymenyToken(paymentId: Int,
                              isBnplEnabled: Bool,
                              completion: @escaping (Result<Void, PayError>) -> Void)
}

final class DefaultPaymentService: PaymentService {
    private let network: NetworkService
    private var sdkManager: SDKManager
    private let userService: UserService
    private let completionManager: CompletionManager
    private var authManager: AuthManager
    private let analytics: AnalyticsService
    private let personalMetricsService: PersonalMetricsService
    private let buildSettings: BuildSettings
    private var paymentToken: PaymentTokenModel?
    private let parsingErrorAnaliticManager: ParsingErrorAnaliticManager
    
    init(authManager: AuthManager,
         network: NetworkService,
         userService: UserService,
         personalMetricsService: PersonalMetricsService,
         completionManager: CompletionManager,
         buildSettings: BuildSettings,
         analytics: AnalyticsService,
         sdkManager: SDKManager,
         parsingErrorAnaliticManager: ParsingErrorAnaliticManager) {
        self.authManager = authManager
        self.network = network
        self.userService = userService
        self.sdkManager = sdkManager
        self.buildSettings = buildSettings
        self.completionManager = completionManager
        self.analytics = analytics
        self.personalMetricsService = personalMetricsService
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func tryToPay(paymentId: Int,
                  isBnplEnabled: Bool,
                  completion: @escaping ((Result<Void, PayError>) -> Void)) {
        tryToGetPaymenyToken(paymentId: paymentId,
                             isBnplEnabled: isBnplEnabled) { result in
            switch result {
            case .success:
                guard let paymentToken = self.paymentToken else { return }
                guard let authInfo = self.sdkManager.authInfo else { return }
                var orderid: String?
                var merchantLogin: String
                
                if isBnplEnabled {
                   self.authManager.apiKey = BnplConstants.apiKey(for: self.buildSettings.networkState)
                    orderid = paymentToken.initiateBankInvoiceId
                    merchantLogin = BnplConstants.merchantLogin(for: self.buildSettings.networkState)
                } else {
                    orderid = authInfo.orderId
                    merchantLogin = self.sdkManager.authInfo?.merchantLogin ?? ""
                }
                switch self.sdkManager.payStrategy {
                case .auto:
                    self.pay(with: paymentToken.paymentToken,
                             orderId: orderid,
                             merchantLogin: merchantLogin,
                             completion: completion)
                case .manual:
                    self.sdkManager.payHandler = { [weak self] payInfo in
                        guard let self else {return }
                        if isBnplEnabled {
                            self.authManager.apiKey = BnplConstants.apiKey(for: self.buildSettings.networkState)
                            orderid = paymentToken.initiateBankInvoiceId
                            merchantLogin = BnplConstants.merchantLogin(for: self.buildSettings.networkState)
                        } else {
                            orderid = payInfo.orderId
                            merchantLogin = self.sdkManager.authInfo?.merchantLogin ?? ""
                        }
                        self.pay(with: payInfo.paymentToken ?? paymentToken.paymentToken,
                                 orderId: orderid,
                                 merchantLogin: merchantLogin,
                                 completion: completion)
                    }
                    self.completionManager.completePaymentToken(with: paymentToken.paymentToken)
                }
            case .failure(let failure):
                if isBnplEnabled {
                    // Если получили с сервака ошибку, отдаем специальную ошибку
                    if failure == .defaultError {
                        completion(.failure(.partPayError))
                    } else {
                        completion(.failure(failure))
                    }
                } else {
                    completion(.failure(failure))
                }
            }
        }
    }
    
    func tryToGetPaymenyToken(paymentId: Int,
                              isBnplEnabled: Bool,
                              completion: @escaping (Result<Void, PayError>) -> Void) {
        self.analytics.sendEvent(.RQPaymentToken,
                                 with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
        getPaymenyToken(paymentId: paymentId,
                        isBnplEnabled: isBnplEnabled,
                        merchantLogin: sdkManager.authInfo?.merchantLogin ?? "") { result in
            switch result {
            case .success(let success):
                self.analytics.sendEvent(.RQGoodPaymentToken,
                                         with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
                self.analytics.sendEvent(.RSGoodPaymentToken,
                                         with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
                self.paymentToken = success
                completion(.success)
            case .failure(let error):
                self.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                    type: .payment(type: .paymentToken))
                completion(.failure(self.parseError(error)))
            }
        }
    }
    
    private func getPaymenyToken(paymentId: Int,
                                 isBnplEnabled: Bool,
                                 merchantLogin: String,
                                 completion: @escaping (Result<PaymentTokenModel, SDKError>) -> Void) {
        guard let sessionId = authManager.sessionId,
              let authInfo = sdkManager.authInfo
        else { return }
        personalMetricsService.getUserData { deviceInfo in
            if let deviceInfo = deviceInfo {
                self.network.request(PaymentTarget.getPaymentToken(sessionId: sessionId,
                                                                   deviceInfo: deviceInfo,
                                                                   paymentId: paymentId,
                                                                   merchantLogin: merchantLogin,
                                                                   orderId: authInfo.orderId,
                                                                   amount: authInfo.amount,
                                                                   currency: authInfo.currency,
                                                                   orderNumber: authInfo.orderNumber,
                                                                   expiry: authInfo.expiry,
                                                                   frequency: authInfo.frequency,
                                                                   isBnplEnabled: isBnplEnabled),
                                     to: PaymentTokenModel.self,
                                     completion: completion)
            } else {
                completion(.failure(SDKError(.personalInfo)))
            }
        }
    }
    
    private func pay(with token: String,
                     orderId: String?,
                     merchantLogin: String,
                     completion: @escaping ((Result<Void, PayError>) -> Void)) {
        network.request(PaymentTarget.getPaymentOrder(operationId: .generateRandom(with: 36),
                                                      orderId: orderId,
                                                      merchantLogin: merchantLogin,
                                                      ipAddress: authManager.ipAddress,
                                                      paymentToken: token),
                        to: PaymentOrderModel.self,
                        retrySettings: (4, [
                            Int(StatusCode.errorSystem.rawValue),
                            Int(StatusCode.unknownPayState.rawValue),
                            Int(StatusCode.unknownState.rawValue)
                        ])) { result in
                            switch result {
                            case .success:
                                self.analytics.sendEvent(.RQGoodPaymentOrder,
                                                         with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
                                self.analytics.sendEvent(.RSGoodPaymentOrder,
                                                         with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
                                completion(.success)
                            case .failure(let error):
                                self.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                                    type: .payment(type: .paymentOrder))
                                completion(.failure(self.parseError(error)))
                                }
                            }
    }
    
    private func parseError(_ sdkError: SDKError) -> PayError {
        if sdkError.represents(.noInternetConnection) {
            return .noInternetConnection
        } else if sdkError.represents(.timeOut) {
            return .timeOut
        } else if sdkError.represents(.system) {
            return .unknownStatus
        } else {
            return  .defaultError
        }
    }
}
