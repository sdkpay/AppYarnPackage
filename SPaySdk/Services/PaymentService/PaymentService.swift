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
    func getChallangeMethod(paymentId: Int,
                            isBnplEnabled: Bool) async throws -> FraudMonСheckResult?
    func tryToPay(paymentId: Int,
                  isBnplEnabled: Bool) async throws
    @discardableResult
    func getPaymentToken(paymentId: Int,
                         isBnplEnabled: Bool) async throws -> PaymentTokenModel
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
    
    func getChallangeMethod(paymentId: Int,
                            isBnplEnabled: Bool) async throws -> FraudMonСheckResult? {
        try await getPaymentToken(paymentId: paymentId, isBnplEnabled: isBnplEnabled).fraudMonСheckResult
    }
    
    func tryToPay(paymentId: Int,
                  isBnplEnabled: Bool) async throws {
        
        do {
            let paymentToken = try await getPaymentToken(paymentId: paymentId, isBnplEnabled: isBnplEnabled)
            
            let (orderid, merchantLogin, _) = try getCredPair(isBnplEnabled)
            
            switch self.sdkManager.payStrategy {
            case .auto:
                try await pay(with: paymentToken.paymentToken, orderId: orderid, merchantLogin: merchantLogin)
            case .manual:
                self.sdkManager.payHandler = { payInfo in
                    Task {
                        try await self.pay(with: payInfo.paymentToken ?? paymentToken.paymentToken,
                                           orderId: orderid,
                                           merchantLogin: merchantLogin)
                    }
                }
                self.completionManager.completePaymentToken(with: paymentToken.paymentToken)
            }
        } catch {
            if error is PayError, isBnplEnabled {
                throw PayError.partPayError
            }
            throw error
        }
    }
    
    @discardableResult
    func getPaymentToken(paymentId: Int,
                         isBnplEnabled: Bool) async throws -> PaymentTokenModel {
        
        guard let sessionId = authManager.sessionId,
              let authInfo = sdkManager.authInfo,
              let merchantLogin = sdkManager.authInfo?.merchantLogin
        else { throw SDKError(.noData) }
        
        do {
            let deviceInfo = try await personalMetricsService.getUserData()
            
            let token = try await network.request(PaymentTarget.getPaymentToken(sessionId: sessionId,
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
                                                  to: PaymentTokenModel.self)
            
            self.analytics.sendEvent(.RQGoodPaymentToken,
                                     with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
            self.analytics.sendEvent(.RSGoodPaymentToken,
                                     with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
            
            self.paymentToken = token
            
            return token
        } catch {
            
            if let error = error as? SDKError {
                self.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                    type: .payment(type: .paymentToken))
                throw self.parseError(error)
            }
            
            throw error
        }
    }
    
    private func pay(with token: String,
                     orderId: String?,
                     merchantLogin: String) async throws {
        
        do {
            try await network.request(PaymentTarget.getPaymentOrder(operationId: .generateRandom(with: 36),
                                                                    orderId: orderId,
                                                                    merchantLogin: merchantLogin,
                                                                    ipAddress: authManager.ipAddress,
                                                                    paymentToken: token),
                                      retrySettings: (4, [
                                        Int(StatusCode.errorSystem.rawValue),
                                        Int(StatusCode.unknownPayState.rawValue),
                                        Int(StatusCode.unknownState.rawValue)
                                      ]))
            
            self.analytics.sendEvent(.RQGoodPaymentOrder,
                                     with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
            self.analytics.sendEvent(.RSGoodPaymentOrder,
                                     with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
        } catch {
            if let error = error as? SDKError {
                self.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                    type: .payment(type: .paymentOrder))
                throw self.parseError(error)
            }
            
            throw error
        }
    }
    
    private func getCredPair(_ isBnplEnabled: Bool) throws -> (orderid: String, merchantLogin: String, apiKey: String) {
        
        guard let authInfo = self.sdkManager.authInfo else { throw SDKError(.noData) }
        guard let paymentToken = self.paymentToken else { throw SDKError(.noData) }
        
        switch isBnplEnabled {
        case true:
            return (
                orderid: paymentToken.initiateBankInvoiceId ?? "",
                merchantLogin: BnplConstants.merchantLogin(for: self.buildSettings.networkState),
                apiKey: BnplConstants.apiKey(for: self.buildSettings.networkState)
            )
        case false:
            return (
                orderid: authInfo.orderId ?? "",
                merchantLogin: self.sdkManager.authInfo?.merchantLogin ?? "",
                apiKey: self.authManager.apiKey ?? ""
            )
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
