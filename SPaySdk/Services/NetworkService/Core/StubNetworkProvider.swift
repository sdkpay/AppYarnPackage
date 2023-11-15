//
//  StubNetworkProvider.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import UIKit

final class StubNetworkProvider: NSObject, NetworkProvider {
 
    private let delayedSeconds: Double
    private var dispatchWorkItem: DispatchWorkItem?
    private var hostManager: HostManager

    init(delayedSeconds: Double = 0, hostManager: HostManager) {
        self.delayedSeconds = delayedSeconds
        self.hostManager = hostManager
        super.init()
    }

    func request(_ target: TargetType,
                 retrySettings: RetrySettings,
                 host: HostSettings) async throws -> (data: Data, response: URLResponse) {
        
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
        
        return (sampleData, response)
    }
    
    func request(_ target: TargetType,
                 retrySettings: RetrySettings,
                 host: HostSettings,
                 completion: @escaping NetworkProviderCompletion) {
        let response = HTTPURLResponse(url: hostManager.host(for: host),
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        dispatchWorkItem = DispatchWorkItem {
            completion(target.sampleData, response, nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(Int(500)),
                                      execute: dispatchWorkItem!)
    }
    
    func cancel() {
        if let dispatchWorkItem = dispatchWorkItem {
            dispatchWorkItem.cancel()
        }
    }
}
