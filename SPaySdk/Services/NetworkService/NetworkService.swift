//
//  NetworkService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import UIKit

final class NetworkServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        var provider: NetworkProvider
        
        switch container.resolve(BuildSettings.self).networkState {
        case .Prom, .Mocker, .Psi, .Ift:
            provider = DefaultNetworkProvider(requestManager: container.resolve(),
                                              hostManager: container.resolve(),
                                              buildSettings: container.resolve())
        case .Local:
            provider = StubNetworkProvider(delayedSeconds: 2, hostManager: container.resolve())
        }
        
        let service: NetworkService = DefaultNetworkService(provider: provider)
        container.register(service: service)
    }
}

protocol NetworkService: AnyObject {
    func request(_ target: TargetType,
                 retrySettings: RetrySettings,
                 completion: @escaping (Result<Void, SDKError>) -> Void)
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    retrySettings: RetrySettings,
                    completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable
    func cancelTask()
}

extension NetworkService {
    func request(_ target: TargetType,
                 retrySettings: RetrySettings = (1, []),
                 completion: @escaping (Result<Void, SDKError>) -> Void) {
        request(target, retrySettings: retrySettings, completion: completion)
    }
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    retrySettings: RetrySettings = (1, []),
                    completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable {
        request(target, to: to, retrySettings: retrySettings, completion: completion)
    }
}

final class DefaultNetworkService: NetworkService, ResponseDecoder {
    
    private let provider: NetworkProvider
    
    init(provider: NetworkProvider) {
        self.provider = provider
    }

    func request(_ target: TargetType,
                 retrySettings: RetrySettings = (1, []),
                 completion: @escaping (Result<Void, SDKError>) -> Void) {
        provider.request(target, retrySettings: retrySettings) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error)
            completion(result)
        }
    }
    
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    retrySettings: RetrySettings = (1, []),
                    completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable {
        provider.request(target, retrySettings: retrySettings) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error, type: to)
            completion(result)
        }
    }
    
    func cancelTask() {
        provider.cancel()
    }
}
