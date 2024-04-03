//
//  PartPayRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 26.04.2023.
//

import UIKit

protocol PartPayRouting {
    @MainActor
    func presentWebView(with url: String)
}

final class PartPayRouter: PartPayRouting {
    
    weak var viewController: ContentVC?
    private let paymentRouteMap: PaymentRouteMap
    
    init(with paymentRouteMap: PaymentRouteMap) {
        self.paymentRouteMap = paymentRouteMap
    }
    
    @MainActor
    func presentWebView(with url: String) {
        
        guard let contentNC = viewController?.contentNavigationController else { return }
        
        paymentRouteMap.presentWebView(by: CoverPushTransition(pushInto: contentNC), with: url)
    }
}
