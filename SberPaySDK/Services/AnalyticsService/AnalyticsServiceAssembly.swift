//
//  AnalyticsServiceAssembly.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 02.02.2023.
//

import Foundation

final class AnalyticsServiceAssembly: Assembly {
    func register(in locator: LocatorService) {
        let service: AnalyticsService = DefaultAnalyticsService()
        locator.register(service: service)
    }
}
