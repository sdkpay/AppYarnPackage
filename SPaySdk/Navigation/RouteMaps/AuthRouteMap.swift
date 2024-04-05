//
//  AuthRouteMap.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.04.2024.
//

import Foundation
import Combine

final class AuthRouteMapAssembly: Assembly {
    
    var type = ObjectIdentifier(AuthRouteMap.self)
    
    func register(in locator: LocatorService) {
        locator.register {
            let service: AuthRouteMap = DefaultAuthRouteMap(with: locator)
            return service
        }
    }
}

protocol AuthRouteMap: AnyObject {
    
    @MainActor
    func presentPayment(by transition: Transition, state: PaymentVCMode)
    @MainActor
    func presentFakeScreen(by transition: Transition) async
    @MainActor
    func presentBankAppPicker(by transition: Transition) async
    @MainActor
    func presentHelper(by transition: Transition)
    @MainActor
    func presentCards(by transition: Transition,
                      cards: [PaymentTool],
                      cost: String,
                      selectedId: Int) async -> PaymentTool
}

final class DefaultAuthRouteMap: AuthRouteMap {

    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor
    func presentPayment(by transition: Transition, state: PaymentVCMode) {
        
        PaymentMasterAssembly(locator: locator).createModule(transition: transition, state: state)
    }
    
    @MainActor
    func presentFakeScreen(by transition: Transition) async {
        
        await withCheckedContinuation { continuation in
            let vc = FakeViewController {
                continuation.resume()
            }
            transition.performTransition(for: vc)
        }
    }
    
    @MainActor
    func presentBankAppPicker(by transition: Transition) async {
        
        await withCheckedContinuation { continuation in
            BankAppPickerAssembly(locator: locator).createModule(transition: transition) {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    func presentHelper(by transition: Transition) {
        
        HelperAssembly(locator: locator).createModule(transition: transition)
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
