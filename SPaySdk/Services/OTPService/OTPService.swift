//
//  OTPService.swift
//  SPaySdk
//
//  Created by Арсений on 08.08.2023.
//

import Foundation

var modilePhone: String = ""

final class OTPServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: OTPService = DefaultOTPService(network: container.resolve(),
                                                        authManager: container.resolve())
            return service
        }
    }
}

protocol OTPService {
    func creteOTP(orderId: String,
                  paymentId: Int,
                  completion: @escaping (Result<String?, SDKError>) -> Void)
    func confirmOTP(orderId: String,
                    orderHash: String,
                    completion: @escaping (Result<Void, SDKError>) -> Void)
}

final class DefaultOTPService: OTPService, ResponseDecoder {
    
    private let network: NetworkService
    private let authManager: AuthManager
    
    init(network: NetworkService, authManager: AuthManager) {
        self.network = network
        self.authManager = authManager
    }
    
    func creteOTP(orderId: String,
                  paymentId: Int,
                  completion: @escaping (Result<String?, SDKError>) -> Void) {
        network.request(OTPTarget.createOtpSdk(bankInvoiceId: orderId,
                                               sessionId: authManager.sessionId ?? "",
                                               paymentId: paymentId),
                        to: OTPModel.self) { result in
            switch result {
            case .success(let result):
                completion(.success(result.mobilePhone))
            case .failure(let error):
                completion(.failure(error))            }
        }
    }
    
    func confirmOTP(orderId: String,
                    orderHash: String,
                    completion: @escaping (Result<Void, SDKError>) -> Void) {
        network.request(OTPTarget.confirmOtp(bankInvoiceId: orderId,
                                             otpHash: orderHash,
                                             merchantLogin: nil,
                                             sessionId: authManager.sessionId ?? ""),
                        to: OTPModel.self) { result in
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
