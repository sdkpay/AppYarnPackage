//
//  StubNetworkProvider.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import UIKit

final class StubNetworkProvider: NSObject, NetworkProvider {
    let delayedSeconds: Int

    init(delayedSeconds: Int = 0) {
        self.delayedSeconds = delayedSeconds
        super.init()
    }
    
    func request(_ route: TargetType,
                 completion: @escaping NetworkProviderCompletion) {
        let response = HTTPURLResponse(url: ServerURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delayedSeconds)) {
            completion(route.sampleData, response, nil)
        }
    }
    
    // TODO: Реализовать
    func cancel() { }
}
