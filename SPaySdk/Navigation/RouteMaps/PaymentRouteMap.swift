//
//  PaymentRouteMap.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.04.2024.
//

import Foundation
import Combine

final class PaymentRouteMapAssembly: Assembly {
    
    var type = ObjectIdentifier(PaymentRouteMap.self)
    
    func register(in locator: LocatorService) {
        locator.register {
            let service: PaymentRouteMap = DefaultPaymentRouteMap(with: locator)
            return service
        }
    }
}

protocol PaymentRouteMap: AnyObject {
    @MainActor
    func presentCards(by transition: Transition,
                      cards: [PaymentTool],
                      cost: String,
                      selectedId: Int) async -> PaymentTool
    @MainActor
    func presentPartPay(by transition: Transition) async
    @MainActor
    func presentChallenge(by transition: Transition) async -> SecureChallengeResolution
    @MainActor
    func presentWebView(by transition: Transition, with url: String)
    @MainActor
    func openProfile(by transition: Transition, with userInfo: UserInfo)
    @MainActor
    func presentPartPayPayment(by transition: Transition)
}

final class DefaultPaymentRouteMap: PaymentRouteMap {
    
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    func presentPartPay(by transition: Transition) async {
        
        await withCheckedContinuation { continuation in
            PartPayAssembly(locator: locator).createModule(transition: transition,
                                                           partPaySelected: {
                continuation.resume()
            })
        }
    }
    
    func presentChallenge(by transition: Transition) async -> SecureChallengeResolution {
        
        await withCheckedContinuation { continuation in
            ChallengeAssembly(locator: locator).createModule(transition: transition) { resolution in
                continuation.resume(returning: resolution)
            }
        }
    }
    
    func presentWebView(by transition: Transition, with url: String) {
        
        WebViewAssembly(locator: locator).createModule(transition: transition, with: url)
    }
    
    func openProfile(by transition: Transition, with userInfo: UserInfo) {
        
      LogoutAssembly(locator: locator).createModule(transition: transition, with: userInfo)
    }
    
    func presentPartPayPayment(by transition: Transition) {
        PaymentMasterAssembly(locator: locator).createModule(transition: transition, state: .partPay)
    }

    @MainActor
    func presentOTP(by transition: Transition) async {
        
        await withCheckedContinuation { continuation in
            OtpAssembly(locator: locator).createModule(transition: transition) {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    func presentCards(by transition: Transition,
                      cards: [PaymentTool],
                      cost: String,
                      selectedId: Int) async -> PaymentTool {
        await withCheckedContinuation { continuation in
            CardsAssembly(locator: locator).createModule(transition: transition,
                                                         cards: cards,
                                                         cost: cost,
                                                         selectedId: selectedId) { tool in
                continuation.resume(returning: tool)
            }
        }
    }
}
