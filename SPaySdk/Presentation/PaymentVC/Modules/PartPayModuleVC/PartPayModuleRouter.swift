//
//  PartPayModuleRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.03.2024.
//

import UIKit

protocol PartPayModuleRouting: UrlOpenable {
    
    @MainActor
    func presentWebView(with url: String)
    
    var viewController: ModuleVC? { get set }
}

final class PartPayModuleRouter: PartPayModuleRouting {
    
    weak var viewController: ModuleVC?
    private let paymentRouteMap: PaymentRouteMap
    
    init(with paymentRouteMap: PaymentRouteMap) {
        self.paymentRouteMap = paymentRouteMap
    }

    @MainActor
    func presentWebView(with url: String) {
        
        guard let contentNC = viewController?.contentParrent?.contentNavigationController else { return }
        
        paymentRouteMap.presentWebView(by: CoverPushTransition(pushInto: contentNC), with: url)
    }
}
