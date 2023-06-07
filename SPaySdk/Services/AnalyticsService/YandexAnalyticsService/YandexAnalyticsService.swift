//
//  YandexAnalyticsService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 07.06.2023.
//

import Foundation
@_implementationOnly import YandexMobileMetrica

private extension String {
    static let error = "YandexMetrica error: "
}

final class DefaultYandexAnalyticsService: AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent) {
        YMMYandexMetrica.reportEvent(event.rawValue, onFailure: { error in
            SBLogger.log(level: .debug(level: .analytics), .error + error.localizedDescription)
        })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: String...) {
        send(event, with: strings)
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: Int...) {
        send(event, with: ints)
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: Double...) {
        send(event, with: doubles)
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: [String]) {
        send(event, with: strings)
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: [Int]) {
        send(event, with: ints)
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: [Double]) {
        send(event, with: doubles)
    }
    
    private func send(_ event: AnalyticsEvent, with params: [Any]) {
        var parameters: [AnyHashable: Any] = [:]
        params.forEach({ parameters[event.rawValue] = $0 })
        YMMYandexMetrica.reportEvent(event.rawValue,
                                     parameters: parameters,
                                     onFailure: { error in
            SBLogger.log(level: .debug(level: .analytics), .error + error.localizedDescription)
        })
    }
    
    func config() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "12312312312312312131312") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
}
