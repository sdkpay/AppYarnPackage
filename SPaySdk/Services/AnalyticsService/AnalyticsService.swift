//
//  AnalyticsService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.12.2022.
//

import Foundation

final class AnalyticsServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(AnalyticsService.self)
    
    func register(in locator: LocatorService) {
        let service: AnalyticsService = DefaultAnalyticsService()
        locator.register(service: service)
    }
}

enum AnalyticsValue: String {
    case Location
}

protocol AnalyticsService {
    func sendEvent(_ event: String)
    func sendEvent(_ event: String, with string: String)
    func sendEvent(_ event: String, with dictionaty: [AnalyticsKey: String])
    func config()
    func startSession()
    func finishSession()
}

final class DefaultAnalyticsService: NSObject, AnalyticsService {
    
    func startSession() {
        analyticServices.forEach { $0.startSession() }
    }
    
    func finishSession() {
        analyticServices.forEach { $0.finishSession() }
    }
    
    private lazy var analyticServices: [AnalyticsService] = [
        DefaultDynatraceAnalyticsService()
    ]
    
    func sendEvent(_ event: String) {
        
        analyticServices.forEach({ $0.sendEvent(event) })
    }
    
    func sendEvent(_ event: String, with string: String) {
        
        analyticServices.forEach({ $0.sendEvent(event, with: string) })
    }
    
    func sendEvent(_ event: String, with dictionaty: [AnalyticsKey: String]) {
        
        analyticServices.forEach({ $0.sendEvent(event, with: dictionaty) })
    }
    
    override init() {
        super.init()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        self.finishSession()
        SBLogger.log(.stop(obj: self))
    }
    
    func config() {
        analyticServices.forEach({ $0.config() })
        sendEvent("SDKVersion", with: Bundle.sdkVersion)
        startSession()
    }
}
