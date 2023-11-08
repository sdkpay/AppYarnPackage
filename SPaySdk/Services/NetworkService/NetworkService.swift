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
            provider = StubNetworkProvider(delayedSeconds: 1, hostManager: container.resolve())
        }
        
        let service: NetworkService = DefaultNetworkService(provider: provider,
                                                            analyticsService: container.resolve())
        container.register(service: service)
    }
}

protocol NetworkService: AnyObject {
    func request(_ target: TargetType,
                 host: HostSettings,
                 retrySettings: RetrySettings,
                 completion: @escaping (Result<Void, SDKError>) -> Void)
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    host: HostSettings,
                    retrySettings: RetrySettings,
                    completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable
    func requestString(_ target: TargetType,
                       host: HostSettings,
                       retrySettings: RetrySettings,
                       completion: @escaping (Result<String, SDKError>) -> Void)
    func requestFull<T>(_ target: TargetType,
                        to: T.Type,
                        host: HostSettings,
                        retrySettings: RetrySettings,
                        completion: @escaping (Result<(result: T,
                                                       headers: HTTPHeaders,
                                                       cookies: [HTTPCookie]),
                                               SDKError>) -> Void) where T: Codable
    func cancelTask()
}

extension NetworkService {
    func request(_ target: TargetType,
                 host: HostSettings = .main,
                 retrySettings: RetrySettings = (1, []),
                 completion: @escaping (Result<Void, SDKError>) -> Void) {
        request(target, host: host, retrySettings: retrySettings, completion: completion)
    }
    
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    host: HostSettings = .main,
                    retrySettings: RetrySettings = (1, []),
                    completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable {
        request(target, to: to, host: host, retrySettings: retrySettings, completion: completion)
    }
    
    func requestString(_ target: TargetType,
                       host: HostSettings = .main,
                       retrySettings: RetrySettings = (1, []),
                       completion: @escaping (Result<String, SDKError>) -> Void) {
        requestString(target, host: host, retrySettings: retrySettings, completion: completion)
    }
    
    func requestFull<T>(_ target: TargetType,
                        to: T.Type,
                        host: HostSettings = .main,
                        retrySettings: RetrySettings = (1, []),
                        completion: @escaping (Result<(result: T,
                                                       headers: HTTPHeaders,
                                                       cookies: [HTTPCookie]),
                                               SDKError>) -> Void) where T: Codable {
        requestFull(target, to: to, host: host, retrySettings: retrySettings, completion: completion)
    }
}

final class DefaultNetworkService: NetworkService, ResponseDecoder {
    
    private let provider: NetworkProvider
    private let analyticsService: AnalyticsService
    
    init(provider: NetworkProvider, analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
        self.provider = provider
    }

    func request(_ target: TargetType,
                 host: HostSettings,
                 retrySettings: RetrySettings = (1, []),
                 completion: @escaping (Result<Void, SDKError>) -> Void) {
        provider.request(target, retrySettings: retrySettings, host: host) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error)
            completion(result)
        }
    }
    
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    host: HostSettings,
                    retrySettings: RetrySettings = (1, []),
                    completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable {
        provider.request(target, retrySettings: retrySettings, host: host) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error, type: to)
            completion(result)
        }
    }
    
    func requestString(_ target: TargetType,
                       host: HostSettings = .main,
                       retrySettings: RetrySettings = (1, []),
                       completion: @escaping (Result<String, SDKError>) -> Void) {
        provider.request(target, retrySettings: retrySettings, host: host) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error, type: String.self)
            completion(result)
        }
    }
    
    func requestFull<T>(_ target: TargetType,
                        to: T.Type,
                        host: HostSettings,
                        retrySettings: RetrySettings = (1, []),
                        completion: @escaping (Result<(result: T,
                                                       headers: HTTPHeaders,
                                                       cookies: [HTTPCookie]),
                                               SDKError>) -> Void) where T: Codable {
        provider.request(target, retrySettings: retrySettings, host: host) { data, response, error in
            let result = self.decodeResponseFull(data: data, response: response, error: error, type: to)
            completion(result)
        }
    }
    
    func cancelTask() {
        provider.cancel()
    }
    
    func request(_ target: TargetType,
                 host: HostSettings,
                 retrySettings: RetrySettings = (1, [])) async -> Result<Void, SDKError> {
        provider.request(target, retrySettings: retrySettings, host: host) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error)
          
        }
    }
}
