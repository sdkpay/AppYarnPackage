//
//  SDKRouteMap.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.04.2024.
//

import Foundation

final class SDKRouteMapAssembly: Assembly {
    
    var type = ObjectIdentifier(SDKRouteMap.self)
    
    func register(in locator: LocatorService) {
        locator.register {
            let service: SDKRouteMap = DefaultSDKRouteMap(with: locator)
            return service
        }
    }
}

protocol SDKRouteMap: AnyObject {
    
    @MainActor
    func openAuth(by transition: Transition)
}

final class DefaultSDKRouteMap: SDKRouteMap {

    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor
    func openAuth(by transition: Transition) {
        
        AuthAssembly(locator: locator).createModule(transition: transition)
    }
}
