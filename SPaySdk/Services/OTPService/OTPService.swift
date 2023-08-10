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
            let service: AuthService = DefaultAuthService(network: container.resolve(),
                                                          sdkManager: container.resolve(),
                                                          analytics: container.resolve(),
                                                          bankAppManager: container.resolve(),
                                                          authManager: container.resolve(),
                                                          partPayService: container.resolve(),
                                                          personalMetricsService: container.resolve(),
                                                          enviromentManager: container.resolve())
            return service
        }
    }
}

protocol OTPService {
    func creteOTP(orderId: String,
                  sessionId: String,
                  paymentId: Int,
                  completion: @escaping (SDKError?, Bool, String?) -> Void)
    func confirmOTP(orderId: String,
                    orderHash: String,
                    sessionId: String,
                    completion: @escaping (SDKError?, Bool) -> Void)
}

final class DefaultOTPService: OTPService, ResponseDecoder {
    
    private let network: NetworkService
    
    init(network: NetworkService) {
        self.network = network
    }
    
    func creteOTP(orderId: String,
                  sessionId: String,
                  paymentId: Int,
                  completion: @escaping (SDKError?, Bool, String?) -> Void) {
        network.request(OTPTarget.createOtpSdk(bankInvoiceId: orderId,
                                               sessionId: sessionId,
                                               paymentId: paymentId),
                        to: OTPModel.self) { result in
            switch result {
            case .success(let result):
                completion(nil, true, result.mobilePhone)
            case .failure(let error):
                completion(error, false, nil)
            }
        }
    }
    
    func confirmOTP(orderId: String,
                    orderHash: String,
                    sessionId: String,
                    completion: @escaping (SDKError?, Bool) -> Void) {
        network.request(OTPTarget.confirmOtp(bankInvoiceId: orderId,
                                             otpHash: orderHash,
                                             merchantLogin: nil,
                                             sessionId: sessionId), to: OTPModel.self) { result in
            switch result {
            case .success:
                completion(nil, false)
            case .failure(let error):
                completion(error, false)
            }
        }
    }
}
