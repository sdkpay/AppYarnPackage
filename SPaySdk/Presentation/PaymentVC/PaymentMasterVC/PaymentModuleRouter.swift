//
//  PaymentRouter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol PaymentRouting: UrlOpenable {
    @MainActor
    func presentCards(cards: [PaymentTool],
                      cost: String,
                      selectedId: Int) async throws -> PaymentTool
    @MainActor
    func presentPartPay() async
    @MainActor
    func presentOTPScreen() async
    @MainActor
    func presentBankAppPicker() async
    @MainActor
    func presentChallenge() async throws -> SecureChallengeResolution
    @MainActor
    func presentWebView(with url: String)
    @MainActor
    func openProfile(with userInfo: UserInfo)
    @MainActor
    func presentPartPayPayment()
}

final class PaymentRouter: PaymentRouting {
    
    weak var viewController: ContentVC?
    private let paymentRouteMap: PaymentRouteMap
    private let challangeRouteMap: ChallengeRouteMap
    private let authRouteMap: AuthRouteMap
    
    init(with paymentRouteMap: PaymentRouteMap,
         challangeRouteMap: ChallengeRouteMap,
         authRouteMap: AuthRouteMap) {
        self.paymentRouteMap = paymentRouteMap
        self.challangeRouteMap = challangeRouteMap
        self.authRouteMap = authRouteMap
    }
    
    func presentWebView(with url: String) {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        paymentRouteMap.presentWebView(by: CoverPushTransition(pushInto: nc),
                                       with: url)
    }
    
    func openProfile(with userInfo: UserInfo) {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        paymentRouteMap.openProfile(by: CoverPushTransition(pushInto: nc),
                                    with: userInfo)
    }
    
    func presentPartPayPayment() {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        paymentRouteMap.presentPartPayPayment(by: CoverPushTransition(pushInto: nc))
    }
    
    func presentCards(cards: [PaymentTool], cost: String, selectedId: Int) async throws -> PaymentTool {
        
        guard let nc = viewController?.contentNavigationController else { throw SDKError(.unowned) }
        
        return await paymentRouteMap.presentCards(by: CoverPushTransition(pushInto: nc),
                                                  cards: cards,
                                                  cost: cost,
                                                  selectedId: selectedId)
    }
    
    func presentPartPay() async {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        await paymentRouteMap.presentPartPay(by: CoverPushTransition(pushInto: nc))
    }
    
    func presentOTPScreen() async {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        await challangeRouteMap.presentOTP(by: CoverPushTransition(pushInto: nc))
    }
    
    func presentBankAppPicker() async {
        
        guard let nc = viewController?.contentNavigationController else { return }
        
        await authRouteMap.presentBankAppPicker(by: CoverPushTransition(pushInto: nc))
    }
    
    func presentChallenge() async throws -> SecureChallengeResolution {
        
        guard let nc = viewController?.contentNavigationController else { throw SDKError(.unowned) }
        
        return await paymentRouteMap.presentChallenge(by: CoverPushTransition(pushInto: nc))
    }
}
