//
//  ChallengeRouteMap.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.04.2024.
//

import Foundation
import Combine

final class ChallengeRouteMapAssembly: Assembly {
    
    var type = ObjectIdentifier(ChallengeRouteMap.self)
    
    func register(in locator: LocatorService) {
        locator.register {
            let service: ChallengeRouteMap = DefaultChallengeRouteMap(with: locator)
            return service
        }
    }
}

protocol ChallengeRouteMap: AnyObject {
    
    @MainActor
    func presentOTP(by transition: Transition) async
}

final class DefaultChallengeRouteMap: ChallengeRouteMap {

    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor
    func presentOTP(by transition: Transition) async {
        
        await withCheckedContinuation { continuation in
            OtpAssembly(locator: locator).createModule(transition: transition) {
                continuation.resume()
            }
        }
    }
}
