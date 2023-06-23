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
                                                                sdkManager: container.resolve())
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
    private let authManager: AuthManager
    private let personalMetricsService: PersonalMetricsService
    private var paymentToken: PaymentTokenModel?
    
    init(authManager: AuthManager,
         network: NetworkService,
         userService: UserService,
         personalMetricsService: PersonalMetricsService,
         sdkManager: SDKManager) {
        self.authManager = authManager
        self.network = network
        self.userService = userService
        self.sdkManager = sdkManager
        self.personalMetricsService = personalMetricsService
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
                if isBnplEnabled {
                    orderid = paymentToken.initiateBankInvoiceId
                } else {
                    orderid = authInfo.orderId
                }
                switch self.sdkManager.payStrategy {
                case .auto:
                    self.pay(with: paymentToken.paymentToken, orderId: orderid, completion: completion)
                case .manual:
                    self.sdkManager.payHandler = { [weak self] payInfo in
                        self?.pay(with: payInfo.paymentToken ?? paymentToken.paymentToken,
                                  orderId: orderid, completion: completion)
                    }
                    self.sdkManager.completionPaymentToken(with: paymentToken.paymentToken)
                }
            case .failure(let failure):
                if isBnplEnabled {
                    // Если получили с сервака ошибку, отдаем специальную ошибку
                    if failure == .defaultError {
                        completion(.failure(.partPayError))
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
        getPaymenyToken(paymentId: paymentId,
                        isBnplEnabled: isBnplEnabled) { result in
            switch result {
            case .success(let success):
                self.paymentToken = success
                completion(.success)
            case .failure(let failure):
                completion(.failure(self.parseError(failure)))
            }
        }
    }
    
    private func getPaymenyToken(paymentId: Int,
                                 isBnplEnabled: Bool,
                                 completion: @escaping (Result<PaymentTokenModel, SDKError>) -> Void) {
        guard let sessionId = authManager.sessionId,
              let authInfo = sdkManager.authInfo
        else { return }
        personalMetricsService.getUserData { deviceInfo in
            if let deviceInfo = deviceInfo {
                self.network.request(PaymentTarget.getPaymentToken(sessionId: sessionId,
                                                                   deviceInfo: deviceInfo,
                                                                   paymentId: paymentId,
                                                                   merchantLogin: authInfo.merchantLogin,
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
                completion(.failure(.personalInfo))
            }
        }
    }

    private func pay(with token: String,
                     orderId: String?,
                     completion: @escaping ((Result<Void, PayError>) -> Void)) {
        guard let authInfo = sdkManager.authInfo else { return }
        network.request(PaymentTarget.getPaymentOrder(operationId: .generateRandom(with: 36),
                                                      orderId: orderId,
                                                      merchantLogin: authInfo.merchantLogin,
                                                      ipAddress: personalMetricsService.ipAddress,
                                                      paymentToken: token),
                        to: PaymentOrderModel.self,
                        retrySettings: (4, [StatusCode.errorFormat.rawValue])) { result in
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(self.parseError(error)))
            }
        }
    }
    
    private func parseError(_ sdkError: SDKError) -> PayError {
        switch sdkError {
        case .noInternetConnection:
            return .noInternetConnection
        case .timeOut:
            return .timeOut
        case .badResponseWithStatus(code: .errorFormat):
            return .unknownStatus
        default:
            return .defaultError
        }
    }
}
