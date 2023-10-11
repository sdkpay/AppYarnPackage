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
        container.register {
            let service: PersonalMetricsService = DefaultPersonalMetricsService(analyticsService: container.resolve(),
                                                                                network: container.resolve())
            return service
        }
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
    private let analyticsService: AnalyticsService
    private let network: NetworkService
    
    init(analyticsService: AnalyticsService,
         network: NetworkService) {
        self.analyticsService = analyticsService
        self.network = network
        super.init()
        config()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func integrityCheck(completion: @escaping (Bool) -> Void) {
        analyticsService.sendEvent(.SCPermissions)
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
               let сompromised = сompromised {

                if сompromised == 0,
                   emulator == 0 {
                    self?.analyticsService.sendEvent(.SCGoodPermissions)
                    completion(true)
                }
            } else {
                self?.analyticsService.sendEvent(.SCFailPermissions, with: [AnalyticsKey.permisson: emulator ?? сompromised ?? 0])
                completion(false)
            }
        }
    }
    
    private func getIp(completion: @escaping StringAction) {
        network.requestString(IpTarget.getIp,
                              host: .safepayonline) { result in
            switch result {
            case .success(let ip):
                completion(ip)
            case .failure:
                completion("")
            }
        }
    }
    
    func getUserData(completion: @escaping (String?) -> Void) {
        analyticsService.sendEvent(.SCBiZone)
        DispatchQueue.global().async { [weak self] in
            guard let data = self?.provider?.report(.mixedWithCoord) else {
                self?.analyticsService.sendEvent(.SCFailBiZone)
                completion(nil)
                return
            }
            self?.analyticsService.sendEvent(.SCGoodBiZone)
            SBLogger.log(.biZone + data)
            self?.getIp { [weak self] ip in
                self?.ipAddress = ip
                completion(self?.formatString(data))
            }
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
