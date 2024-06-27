//
//  ClickstreamAnalyticsService.swift
//  EcomSdk
//
//  Created by Серёгин Михаил Алексеевич on 16.05.2024.
//

import Foundation
import ClickstreamAnalytics

private enum ClickstreamCredential {
    static let url = "https://iftmpclickstream.testonline.sberbank.ru:8097/metrics/ecosystem/sdk-sber-pay-in-app"
    static let apikey = "d12d860723095964741a09ba379620db1ac48784f35133ff6ca5db714311d250"
}

final class DefaultClickstreamAnalyticsService: AnalyticsService {
    
    private var analyticsTools: AnalyticsTools?
    
    func sendEvent(_ event: String) {
        analyticsTools?.clickstream.sendEvent(eventName: event,
                                              eventType: .business,
                                              properties: nil,
                                              location: nil,
                                              timestamp: Date())
    }
    
    func sendEvent(_ event: String, with string: String) {
        analyticsTools?.clickstream.sendEvent(eventName: event,
                                              eventType: .business,
                                              properties: [event: string],
                                              location: nil,
                                              timestamp: Date())
    }
    
    func startSession() { }
    
    func finishSession() { }
    
    func sendEvent(_ event: String, with dictionaty: [AnalyticsKey: String]) {
        
        let values = dictionaty.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }
        
        analyticsTools?.clickstream.sendEvent(eventName: event,
                                              eventType: .business,
                                              properties: values,
                                              location: nil,
                                              timestamp: Date())
    }
    
    func config() {
        
        var debugMode = false
        
#if SDKDEBUG
        guard let clickstreamUrl = URL(string: ClickstreamCredential.url) else { return }
        let apikey = ClickstreamCredential.apikey
        
        debugMode = true
#else
        let apikey = ConfigGlobal.schemas?.clickstreamApiKey
        guard clickstreamUrlString = ConfigGlobal.schemas?.dynatraceUrl,
              let clickstreamUrl = URL(string: clickstreamUrlString)
        else { return }
        
        debugMode = false
        
#endif
        
        analyticsTools = ClickstreamAnalytics.ClickstreamBuilder.build(url: clickstreamUrl,
                                                                       apiKey: apikey,
                                                                       profile: ClickstreamProfile(userLoginId: Bundle.main.displayName),
                                                                       config: ClickstreamAnalyticsConfig(debugMode: true),
                                                                       logger: { print($0) })
    }
}
