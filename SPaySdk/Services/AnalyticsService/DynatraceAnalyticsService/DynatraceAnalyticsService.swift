//
//  DynatraceAnalyticsService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 07.06.2023.
//

import Foundation
// @_implementationOnly import DynatraceStatic

final class DefaultDynatraceAnalyticsService: AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent) {
//        let action = DTXAction.enter(withName: event.rawValue)
//        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: String...) {
//        let action = DTXAction.enter(withName: event.rawValue)
//        strings.forEach({ action?.reportValue(withName: event.rawValue, stringValue: $0) })
//        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: Int...) {
//        let action = DTXAction.enter(withName: event.rawValue)
//        ints.forEach({ action?.reportValue(withName: event.rawValue, intValue: Int64($0)) })
//        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: Double...) {
//        let action = DTXAction.enter(withName: event.rawValue)
//        doubles.forEach({ action?.reportValue(withName: event.rawValue, doubleValue: $0) })
//        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: [String]) {
//        let action = DTXAction.enter(withName: event.rawValue)
//        strings.forEach({ action?.reportValue(withName: event.rawValue, stringValue: $0) })
//        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: [Int]) {
//        let action = DTXAction.enter(withName: event.rawValue)
//        ints.forEach({ action?.reportValue(withName: event.rawValue, intValue: Int64($0)) })
//        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: [Double]) {
//        let action = DTXAction.enter(withName: event.rawValue)
//        doubles.forEach({ action?.reportValue(withName: event.rawValue, doubleValue: $0) })
//        action?.leave()
    }
    
    func config() {
//        let startupDictionary: [String: Any?] = [
//            kDTXApplicationID: ConfigGlobal.schemas?.dynatraceId,
//            kDTXBeaconURL: ConfigGlobal.schemas?.dynatraceUrl,
//            kDTXLogLevel: "OFF"
//        ]
//        Dynatrace.startup(withConfig: startupDictionary as [String: Any])
//        Dynatrace.identifyUser(Bundle.main.displayName)
    }
}
