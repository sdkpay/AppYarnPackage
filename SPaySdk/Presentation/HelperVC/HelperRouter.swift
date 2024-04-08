//
//  HelperRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.12.2023.
//

import UIKit

protocol HelperRouting: UrlOpenable {
    
    @MainActor
    func presentBankAppPicker() async
}

final class HelperRouter: HelperRouting {
    
    weak var viewController: ContentVC?
    private let authRouteMap: AuthRouteMap
    
    init(with authRouteMap: AuthRouteMap) {
        self.authRouteMap = authRouteMap
    }
    
    @MainActor
    func presentBankAppPicker() async {
        
        guard let contentNC = viewController?.contentNavigationController else { return }
        
        await authRouteMap.presentBankAppPicker(by: CoverPushTransition(pushInto: contentNC))
    }
}
