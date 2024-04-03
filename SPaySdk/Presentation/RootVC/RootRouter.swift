//
//  RootRouter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol RootRouting {
    @MainActor
    func presentAuth()
}

final class RootRouter: RootRouting {
    
    weak var viewController: UIViewController?
    private let routeMap: SDKRouteMap
    
    init(with routeMap: SDKRouteMap) {
        self.routeMap = routeMap
    }
    
    @MainActor
    func presentAuth() {
        
        guard let viewController else { return }
        
        routeMap.openAuth(by: CoverWrappingInNavigationTransition(on: viewController,
                                                                  animated: true))
    }
}
