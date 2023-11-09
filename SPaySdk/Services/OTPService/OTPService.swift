//
//  OTPService.swift
//  SPaySdk
//
//  Created by Арсений on 08.08.2023.
//

import Foundation

final class OTPServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: OTPService = DefaultOTPService(network: container.resolve(),
                                                        sdkManager: container.resolve(),
                                                        userService: container.resolve(),
                                                        authManager: container.resolve())
            return service
        }
    }
}

protocol OTPService {
    var otpModel: OTPModel? { get }
    var otpRequired: Bool { get }
    func creteOTP() async throws
    func confirmOTP(otpHash: String,
                    completion: @escaping (Result<Void, SDKError>) -> Void) 
}

final class DefaultOTPService: OTPService, ResponseDecoder {
    
    private let network: NetworkService
    private let authManager: AuthManager
    private let sdkManager: SDKManager
    private let userService: UserService
    
    var otpModel: OTPModel?
    
    var otpRequired: Bool {
        authManager.isOtpNeed ?? true
    }
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         userService: UserService,
         authManager: AuthManager) {
        self.network = network
        self.sdkManager = sdkManager
        self.userService = userService
        self.authManager = authManager
    }
    
    func creteOTP() async throws {
        
        let otpResult = try await network.request(OTPTarget.createOtpSdk(bankInvoiceId: sdkManager.authInfo?.orderId ?? "",
                                                                         sessionId: authManager.sessionId ?? "",
                                                                         paymentId: userService.selectedCard?.paymentId ?? 0),
                                                  to: OTPModel.self)
        self.otpModel = otpResult
    }
    
    func confirmOTP(otpHash: String,
                    completion: @escaping (Result<Void, SDKError>) -> Void) {
        network.request(OTPTarget.confirmOtp(bankInvoiceId: sdkManager.authInfo?.orderId ?? "",
                                             otpHash: otpHash,
                                             merchantLogin: sdkManager.authInfo?.merchantLogin ?? "",
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
