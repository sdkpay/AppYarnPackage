//
//  PersonalMetricsService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 16.01.2023.
//

import Foundation
import Fingerprint

protocol PersonalMetricsService {
    func getUserData(completion: @escaping (String?) -> Void)
}

final class DefaultPersonalMetricsService: NSObject, PersonalMetricsService {
    private var provider: FPReportProviderProtocol?
    
    override init() {
        super.init()
        config()
    }
    
    func getUserData(completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            completion(self?.provider?.report(.mixedWithCoord))
        }
    }
    
    private func config() {
        let config = FPConfiguration()
        config.cachingTime = .testPeriodFor20Sec
        config.keyForHMACHash = "TestKey"
        config.useRSAAppkey = false
        config.useAdvertiserID = false
        provider = FPSDKFactory.create(withConfiguration: config)
    }
}
