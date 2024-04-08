//
//  SecureChallengeService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 16.11.2023.
//

import Foundation

enum SecureChallengeResolution: String {
    case confirmedGenuine = "CONFIRMED_GENUINE"
    case confirmedFraud = "CONFIRMED_FRAUD"
    case unknown = "UNKNOWN"
}

final class SecureChallengeServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(SecureChallengeService.self)
    
    func register(in locator: LocatorService) {
        let service: SecureChallengeService = DefaultSecureChallengeService(locator.resolve(),
                                                                            sdkManager: locator.resolve(),
                                                                            paymentService: locator.resolve())
        locator.register(service: service)
    }
}

protocol SecureChallengeService {
    
    func challenge(paymentId: Int, isBnplEnabled: Bool) async throws -> SecureChallengeState?
    var fraudMonСheckResult: FraudMonСheckResult? { get set }
    func sendChallengeResult(resolution: SecureChallengeResolution?) async throws
}

final class DefaultSecureChallengeService: SecureChallengeService {
    
    private var network: NetworkService
    private var paymentService: PaymentService
    private var paymentId: Int?
    private let sdkManager: SDKManager
    private var isBnplEnabled = false
    
    var fraudMonСheckResult: FraudMonСheckResult?
    
    init(_ network: NetworkService,
         sdkManager: SDKManager,
         paymentService: PaymentService) {
        self.network = network
        self.sdkManager = sdkManager
        self.paymentService = paymentService
    }
    
    func challenge(paymentId: Int, isBnplEnabled: Bool) async throws -> SecureChallengeState? {
        
        self.paymentId = paymentId
        self.isBnplEnabled = isBnplEnabled
        
        do {
            try await paymentService.getPaymentToken(paymentId: paymentId,
                                                     isBnplEnabled: isBnplEnabled,
                                                     resolution: nil)
            fraudMonСheckResult = nil
        } catch {
            if let sdkError = error as? SDKError,
               let secureError = SecureChallengeError(from: sdkError) {
                
                fraudMonСheckResult = secureError.fraudMonСheckResult
            } else {
                throw error
            }
        }
        return fraudMonСheckResult?.secureChallengeState
    }
    
    func sendChallengeResult(resolution: SecureChallengeResolution?) async throws {
        try await paymentService.getPaymentToken(paymentId: paymentId ?? 0,
                                                 isBnplEnabled: isBnplEnabled,
                                                 resolution: resolution)
    }
}
