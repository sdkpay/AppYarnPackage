//
//  SecureChallengeService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 16.11.2023.
//

import Foundation

final class SecureChallengeServiceAssembly: Assembly {
    func register(in locator: LocatorService) {
        let service: SecureChallengeService = DefaultSecureChallengeService()
        locator.register(service: service)
    }
}

protocol SecureChallengeService {
}

final class DefaultSecureChallengeService: SecureChallengeService {
    
    init() {}
}
