//
//  StubNetworkProvider.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import UIKit

final class StubNetworkProvider: NSObject, NetworkProvider {
 
    private let delayedSeconds: Double
    private var hostManager: HostManager
    private var analytics: AnalyticsManager

    init(delayedSeconds: Double = 0,
         hostManager: HostManager,
         analytics: AnalyticsManager) {
        self.delayedSeconds = delayedSeconds
        self.hostManager = hostManager
        self.analytics = analytics
        super.init()
    }

    func request(_ target: TargetType,
                 retrySettings: RetrySettings,
                 host: HostSettings) async throws -> (data: Data, response: URLResponse) {

        analytics.sendRequestStarted(target)
        
        if #available(iOS 16.0, *) {
            try await Task.sleep(until: .now + .seconds(delayedSeconds), clock: .continuous)
        } else {
            try await Task.sleep(nanoseconds: UInt64(delayedSeconds) * 1000000000)
        }
        
        guard let response = HTTPURLResponse(url: hostManager.host(for: host),
                                             statusCode: 200,
                                             httpVersion: nil,
                                             headerFields: nil) else {
            fatalError("Неправильно составлен стабовый запрос")
        }
        
        let sampleData = target.sampleData ?? Data()
        
        analytics.sendRequestCompleted(target, data: sampleData, response: response, error: nil)
        
        return (sampleData, response)
    }

    func cancel() {
    }
}
