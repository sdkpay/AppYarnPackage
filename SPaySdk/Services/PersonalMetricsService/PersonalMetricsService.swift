//
//  PersonalMetricsService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 16.01.2023.
//

import Foundation
@_implementationOnly import Fingerprint

final class PersonalMetricsServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: PersonalMetricsService = DefaultPersonalMetricsService()
        container.register(service: service)
    }
}

protocol PersonalMetricsService {
    var ipAddress: String? { get }
    func getUserData(completion: @escaping (String?) -> Void)
    func integrityCheck(completion: @escaping (Bool) -> Void)
}

final class DefaultPersonalMetricsService: NSObject, PersonalMetricsService {
    private var provider: FPReportProviderProtocol?
    private(set) var ipAddress: String?
    
    override init() {
        super.init()
        config()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func integrityCheck(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let data = self?.provider?.report(.mixedWithCoord) else {
                completion(false)
                return
            }
            SBLogger.log(.biZone + data)
            // Строку с данными конвертируем в словать
            let dataDictionary = self?.convertToDictionary(text: data)
            // Значение присутствия эмулятора
            let emulator = dataDictionary?["Emulator"] as? Int
            // Значениие Root detector
            let сompromised = dataDictionary?["Compromised"] as? Int
            // Проверяем значение
            if let emulator = emulator,
               let сompromised = сompromised,
               сompromised == 0,
               emulator == 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getUserData(completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let data = self?.provider?.report(.mixedWithCoord) else {
                completion(nil)
                return
            }
            SBLogger.log(.biZone + data)
            let dataDictionary = self?.convertToDictionary(text: data)
            self?.ipAddress = dataDictionary?["LocalIPv4"] as? String
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
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
