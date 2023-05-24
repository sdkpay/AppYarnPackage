//
//  StubNetworkProvider.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import UIKit

final class StubNetworkProvider: NSObject, NetworkProvider {
    private let delayedSeconds: Int
    private var dispatchWorkItem: DispatchWorkItem?
    private var hostManager: HostManager

    init(delayedSeconds: Int = 0, hostManager: HostManager) {
        self.delayedSeconds = delayedSeconds
        self.hostManager = hostManager
        super.init()
    }
    
    func request(_ target: TargetType,
                 retrySettings: RetrySettings,
                 completion: @escaping NetworkProviderCompletion) {
        let response = HTTPURLResponse(url: hostManager.host,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        dispatchWorkItem = DispatchWorkItem {
            completion(target.sampleData, response, nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delayedSeconds),
                                      execute: dispatchWorkItem!)
    }
    
    func cancel() {
        if let dispatchWorkItem = dispatchWorkItem {
            dispatchWorkItem.cancel()
        }
    }
}
