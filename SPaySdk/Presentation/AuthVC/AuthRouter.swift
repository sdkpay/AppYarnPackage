//
//  AuthRouter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit
import Combine

protocol AuthRouting {
    @MainActor
    func presentPayment(state: PaymentVCMode)
    @MainActor
    func presentFakeScreen() async
    @MainActor
    func presentBankAppPicker() async
    @MainActor
    func presentHelper()
}

final class AuthRouter: AuthRouting {

    weak var viewController: ContentVC?
    private let routeMap: AuthRouteMap
    
    init(with routeMap: AuthRouteMap) {
        self.routeMap = routeMap
    }
    
    @MainActor
    func presentCards(cards: [PaymentTool], selectedId: Int) async throws -> PaymentTool {
        
        guard let nc = viewController?.contentNavigationController else { throw SDKError(.unowned) }
        
        return await routeMap.presentCards(by: CoverPushTransition(pushInto: nc),
                                           cards: cards,
                                           selectedId: selectedId)
    }
    
    @MainActor
    func presentPayment(state: PaymentVCMode) {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        routeMap.presentPayment(by: CoverPushTransition(pushInto: nc),
                                state: state)
    }
    
    @MainActor
    func presentBankAppPicker() async {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        await routeMap.presentBankAppPicker(by: CoverPushTransition(pushInto: nc))
    }
    
    @MainActor
    func presentFakeScreen() async {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        await routeMap.presentFakeScreen(by: PresentTransition(pushInto: nc))
    }
    
    @MainActor
    func presentHelper() {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        routeMap.presentHelper(by: CoverPushTransition(pushInto: nc))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
