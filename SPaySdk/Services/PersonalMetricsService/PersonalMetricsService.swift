//
//  PersonalMetricsService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 16.01.2023.
//

import Foundation
@_implementationOnly import Fingerprint

extension MetricsValue {
    
    static let permissions = MetricsValue(rawValue: "Permissions")
    static let biZone = MetricsValue(rawValue: "BiZone")
}

final class PersonalMetricsServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(PersonalMetricsService.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: PersonalMetricsService = DefaultPersonalMetricsService(analytics: container.resolve(),
                                                                                network: container.resolve())
            return service
        }
    }
}

protocol PersonalMetricsService {
    func getUserData() async throws -> String 
    func integrityCheck() async throws
    func getIp() async -> String
}

final class DefaultPersonalMetricsService: NSObject, PersonalMetricsService {
    private var provider: FPReportProviderProtocol?
    private let analytics: AnalyticsManager
    private let network: NetworkService
    
    init(analytics: AnalyticsManager,
         network: NetworkService) {
        self.analytics = analytics
        self.network = network
        super.init()
        config()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func integrityCheck() async throws {
        analytics.send(EventBuilder().with(base: .SC).with(value: .permissions).build(),
                       on: .AuthView)
        
        guard let data = self.provider?.report(.mixedWithCoord) else {
            throw SDKError(.personalInfo)
        }
        SBLogger.log(.biZone + data)
        // Строку с данными конвертируем в словать
        let dataDictionary = self.convertToDictionary(text: data)
        // Значение присутствия эмулятора
        let emulator = dataDictionary?["Emulator"] as? Int
        // Значениие Root detector
        let сompromised = dataDictionary?["Compromised"] as? Int
        // Проверяем значение
        if let emulator = emulator,
           let сompromised = сompromised {
            
            if сompromised == 0,
               emulator == 0 {
                analytics.send(EventBuilder()
                    .with(base: .SC)
                    .with(value: .permissions)
                    .with(state: .Good)
                    .build(),
                               on: .AuthView)
                return
            }
        } else {
            analytics.send(EventBuilder()
                .with(base: .SC)
                .with(value: .permissions)
                .with(state: .Fail)
                .build(),
                           on: .AuthView, values: [.Permisson: String(emulator ?? сompromised ?? 0)])
            throw SDKError(.personalInfo)
        }
        
        throw SDKError(.personalInfo)
    }
    
    func getIp() async -> String {
        
        let ip = try? await network.requestString(IpTarget.getIp,
                                                  host: .getIp)
        
        return ip ?? "None"
    }
    
    func getUserData() async throws -> String {
        analytics.send(EventBuilder()
            .with(base: .SC)
            .with(value: .biZone)
            .build(),
                       on: .AuthView)
        
        return try await withCheckedThrowingContinuation({( inCont: CheckedContinuation<String, Error>) -> Void in
            
            getUserPrivateData { string in
                if let string = string {
                    inCont.resume(returning: string)
                } else {
                    self.analytics.send(EventBuilder()
                        .with(base: .SC)
                        .with(value: .biZone)
                        .with(postState: .Fail)
                        .build(),
                                   on: .AuthView)
                    inCont.resume(throwing: SDKError(.personalInfo))
                }
            }
        })
    }

   private func getUserPrivateData(completion: @escaping (String?) -> Void) {
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
