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
    func tryToPay(paymentId: Int, isBnplEnabled: Bool, completion: @escaping ((Result<Void, PayError>) -> Void))
}

final class DefaultPaymentService: PaymentService {
    private let network: NetworkService
    private var sdkManager: SDKManager
    private let userService: UserService
    private let authManager: AuthManager
    private let personalMetricsService: PersonalMetricsService
    
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
    
    func tryToPay(paymentId: Int, isBnplEnabled: Bool, completion: @escaping ((Result<Void, PayError>) -> Void)) {
        personalMetricsService.getUserData { [weak self] deviceInfo in
            if let deviceInfo = deviceInfo {
                self?.getPaymenyToken(with: deviceInfo,
                                      paymentId: paymentId,
                                      isBnplEnabled: isBnplEnabled,
                                      completion: completion)
            } else {
                completion(.failure(.personalInfo))
            }
        }
    }
    
    private func getPaymenyToken(with deviceInfo: String,
                                 paymentId: Int,
                                 isBnplEnabled: Bool,
                                 completion: @escaping ((Result<Void, PayError>) -> Void)) {
        guard let sessionId = authManager.sessionId,
              let authInfo = sdkManager.authInfo
        else { return }
        network.request(PaymentTarget.getPaymentToken(sessionId: sessionId,
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
                        to: PaymentTokenModel.self) { [weak self] result in
            guard let self = self else { return }
            self.userService.clearData()
            switch result {
            case .success(let result):
                switch self.sdkManager.payStrategy {
                case .auto:
                    self.pay(with: result.paymentToken, completion: completion)
                case .manual:
                    self.sdkManager.payHandler = { [weak self] payInfo in
                        self?.pay(with: payInfo.paymentToken ?? result.paymentToken, completion: completion)
                    }
                    self.sdkManager.completionPaymentToken(with: result.paymentToken)
                }
            case .failure(let error):
                if isBnplEnabled {
                    // Если получили с сервака ошибку, отдаем специальную ошибку
                    if self.parseError(error) == .defaultError {
                        completion(.failure(.partPayError))
                    }
                } else {
                    completion(.failure(self.parseError(error)))
                }
            }
        }
    }
    
    private func pay(with token: String,
                     completion: @escaping ((Result<Void, PayError>) -> Void)) {
        guard let authInfo = sdkManager.authInfo else { return }
        network.request(PaymentTarget.getPaymentOrder(operationId: .generateRandom(with: 36),
                                                      orderId: authInfo.orderId,
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
