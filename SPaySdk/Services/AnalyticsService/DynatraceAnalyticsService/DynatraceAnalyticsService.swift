//
//  DynatraceAnalyticsService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 07.06.2023.
//

import Foundation
 @_implementationOnly import DynatraceStatic

private enum DynatraceCredentional {
    static let url = "https://vito.sbrf.ru:443/mbeacon/7e4bdb68-cd47-4ecc-b649-69eb5cd44c91"
    static let apikey = "63bb5224-894a-41f6-a558-d4ab8e62e21a"
}

final class DefaultDynatraceAnalyticsService: AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent) {
        let action = DTXAction.enter(withName: event.rawValue)
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: String...) {
        let action = DTXAction.enter(withName: event.rawValue)
        strings.forEach({ action?.reportValue(withName: event.rawValue, stringValue: $0) })
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: Int...) {
        let action = DTXAction.enter(withName: event.rawValue)
        ints.forEach({ action?.reportValue(withName: event.rawValue, intValue: Int64($0)) })
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: Double...) {
        let action = DTXAction.enter(withName: event.rawValue)
        doubles.forEach({ action?.reportValue(withName: event.rawValue, doubleValue: $0) })
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: [String]) {
        let action = DTXAction.enter(withName: event.rawValue)
        strings.forEach({ action?.reportValue(withName: event.rawValue, stringValue: $0) })
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: [Int]) {
        let action = DTXAction.enter(withName: event.rawValue)
        ints.forEach({ action?.reportValue(withName: event.rawValue, intValue: Int64($0)) })
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: [Double]) {
        let action = DTXAction.enter(withName: event.rawValue)
        doubles.forEach({ action?.reportValue(withName: event.rawValue, doubleValue: $0) })
        action?.leave()
    }
    
    func startSession(orderNumber: String) {
        Dynatrace.identifyUser(orderNumber)
    }
    
    func finishSession() {
        Dynatrace.endVisit()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with dictionaty: [AnalyticsKey: Any]) {
        let action = DTXAction.enter(withName: event.rawValue)
        dictionaty.forEach { key, value in
            if let value = value as? Int64 {
                action?.reportValue(withName: key.rawValue, intValue: value)
            } else if let value = value as? String {
                action?.reportValue(withName: key.rawValue, stringValue: value)
            } else {
                assertionFailure("Неверный тип для \(value)")
            }
        }
        action?.leave()
    }

    func config() {
#if SDKDEBUG
        let dynatraceId = DynatraceCredentional.apikey
        let dynatraceUrl = DynatraceCredentional.url
#else
        let dynatraceId = ConfigGlobal.schemas?.dynatraceId
        let dynatraceUrl = ConfigGlobal.schemas?.dynatraceUrl
#endif
        let startupDictionary: [String: Any?] = [
            kDTXApplicationID: dynatraceId,
            kDTXBeaconURL: dynatraceUrl,
            kDTXLogLevel: "OFF"
        ]
        Dynatrace.startup(withConfig: startupDictionary as [String: Any])
        Dynatrace.identifyUser(Bundle.main.displayName)
    }
}
