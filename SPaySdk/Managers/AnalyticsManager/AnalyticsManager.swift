//
//  AnalyticsManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 18.03.2024.
//

import UIKit

enum MetricsBaseKey: String {
    
    case Touch
    
    case RQ
    case RS
    
    case ST
    
    case LC
    
    case MA
    case MAC
    
    case SC
}

enum MetricsActionKey: String {
    
    case Touch
    
    case Get
    case Save
    
    case Start
    case End
    
    case Appeared
    case Disappeared
    case Open
}

enum MetricsStateKey: String {
    
    case Good
    case Fail
}



final class MetricsBuilder {
    
    private let base = ""
    private let action = ""
    private let state = ""
    
}

final class AnalyticsServiceManager: Assembly {
    
    var type = ObjectIdentifier(AnalyticsManager.self)
    
    func register(in locator: LocatorService) {
        let service: AnalyticsManager = DefaultAnalyticsManager(service: locator.resolve(),
                                                                authManager: locator.resolve(),
                                                                sdkManager: locator.resolve())
        locator.register(service: service)
    }
}

protocol AnalyticsManager: NSObject {
    
    func send(_ event: AnalyticsEvent, on view: AnlyticsViewName, values: [AnalyticsKey: Any])
}

final class DefaultAnalyticsManager: NSObject, AnalyticsManager {
    
    private let service: AnalyticsService
    private let authManager: AuthManager
    private let sdkManager: SDKManager
    
    init(service: AnalyticsService, authManager: AuthManager, sdkManager: SDKManager) {
        self.service = service
        self.authManager = authManager
        self.sdkManager = sdkManager
    }
    
    func send(_ event: AnalyticsEvent, on view: AnlyticsViewName, values: [AnalyticsKey : Any]) {
        
        var dict = values
        
        dict[.View] = view.rawValue
        
        addSessionParams(to: &dict)
        service.sendEvent(event, with: dict)
    }
    
    private func addSessionParams(to dictionary: inout [AnalyticsKey: Any]) {
        
        dictionary[.OrderNumber] = authManager.orderNumber
        dictionary[.SessionId] = authManager.sessionId
        dictionary[.MerchLogin] = sdkManager.authInfo?.merchantLogin
    }
}

