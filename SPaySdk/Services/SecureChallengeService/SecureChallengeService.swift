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
    func register(in locator: LocatorService) {
        let service: SecureChallengeService = DefaultSecureChallengeService(locator.resolve(),
                                                                            paymentService: locator.resolve())
        locator.register(service: service)
    }
}

protocol SecureChallengeService {
    
    func challenge(paymentId: Int, isBnplEnabled: Bool) async throws -> SecureChallengeState?
    var fraudMonСheckResult: FroudMonСheckResult? { get }
}

final class DefaultSecureChallengeService: SecureChallengeService {
    
    private var network: NetworkService
    private var paymentService: PaymentService
    
    var fraudMonСheckResult: FroudMonСheckResult?
    
    init(_ network: NetworkService,
         paymentService: PaymentService) {
        self.network = network
        self.paymentService = paymentService
    }
    
    func challenge(paymentId: Int, isBnplEnabled: Bool) async throws -> SecureChallengeState? {
        
        do {
            let fraudMonСheckResult = try await paymentService.getPaymentToken(paymentId: paymentId,
                                                                               isBnplEnabled: isBnplEnabled, 
                                                                               resolution: nil).froudMonСheckResult
            self.fraudMonСheckResult = fraudMonСheckResult
            
            return fraudMonСheckResult?.secureChallengeState
        } catch {
            throw error
        }
    }
}
