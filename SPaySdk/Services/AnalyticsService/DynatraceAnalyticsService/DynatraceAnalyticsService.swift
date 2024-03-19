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
    
    func sendEvent(_ event: String) {
        let action = DTXAction.enter(withName: event)
        action?.leave()
    }
    
    func sendEvent(_ event: String, with string: String) {
        let action = DTXAction.enter(withName: event)
        action?.reportValue(withName: event, stringValue: string)
        SBLogger.logAnalyticsEvent(name: event, values: string)
        action?.leave()
    }
    
    func startSession() {
        Dynatrace.identifyUser(Bundle.main.displayName)
    }
    
    func finishSession() {
        Dynatrace.endVisit()
    }
    
    func sendEvent(_ event: String, with dictionaty: [AnalyticsKey: String]) {
        let action = DTXAction.enter(withName: event)
        dictionaty.forEach { key, value in
            action?.reportValue(withName: key.rawValue, stringValue: value)
        }
        let values = dictionaty.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }
        SBLogger.logAnalyticsEvent(name: event, values: values.json)
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
            kDTXLogLevel: "OFF",
            kDTXInstrumentLifecycleMonitoring: false,
            kDTXInstrumentAutoUserAction: false,
            kDTXExcludedControlClasses: [],
            kDTXExcludedControls: []
        ]
        Dynatrace.startup(withConfig: startupDictionary as [String: Any])
    }
}
