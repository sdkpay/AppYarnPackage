//
//  PersonalMetricsService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 16.01.2023.
//

import Foundation
import Fingerprint

final class PersonalMetricsServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: PersonalMetricsService = DefaultPersonalMetricsService()
        container.register(service: service)
    }
}

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
            guard let data = self?.provider?.report(.mixedWithCoord) else {
                completion(nil)
                return
            }
            SBLogger.log(.biZone + data)
            completion(self?.formatString(data))
        }
    }
    
    private func formatString(_ metrics: String) -> String {
        metrics.replacingOccurrences(of: "\n", with: "")
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
