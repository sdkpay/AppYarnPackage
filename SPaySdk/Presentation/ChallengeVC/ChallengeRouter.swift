//
//  ChallengeRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import UIKit

protocol ChallengeRouting {

    @MainActor
    func presentOTPScreen() async
    @MainActor
    func presentBankAppPicker() async
}

final class ChallengeRouter: ChallengeRouting, UrlOpenable {
    
    weak var viewController: ContentVC?
    private let authRouteMap: AuthRouteMap
    private let challangeRouteMap: ChallengeRouteMap
    
    init(with authRouteMap: AuthRouteMap,
         challangeRouteMap: ChallengeRouteMap) {
        self.authRouteMap = authRouteMap
        self.challangeRouteMap = challangeRouteMap
    }

    @MainActor
    func presentOTPScreen() async {
        
        guard let contentNC = viewController?.contentNavigationController else { return }
        
        await challangeRouteMap.presentOTP(by: CoverPushTransition(pushInto: contentNC))
    }
    
    @MainActor
    func presentBankAppPicker() async {
        
        guard let contentNC = viewController?.contentNavigationController else { return }
        
        await authRouteMap.presentBankAppPicker(by: CoverPushTransition(pushInto: contentNC))
    }
}
