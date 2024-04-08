//
//  CardsRouter.swift
//  SPaySdk
//
//  Created by Михаил Серёгин on 08.04.2024.
//

import UIKit
import Combine

protocol CardsRouting {
    @MainActor
    func presentHelper()
}

final class CardsRouter: CardsRouting {

    weak var viewController: ContentVC?
    private let routeMap: AuthRouteMap
    
    init(with routeMap: AuthRouteMap) {
        self.routeMap = routeMap
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
