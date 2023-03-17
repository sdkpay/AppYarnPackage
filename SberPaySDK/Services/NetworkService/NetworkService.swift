//
//  NetworkService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import UIKit

final class NetworkServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        var provider: NetworkProvider

        switch BuildSettings.shared.networkState {
        case .Prod, .Test:
            provider = DefaultNetworkProvider(requestManager: container.resolve())
        case .Local:
            provider = StubNetworkProvider(delayedSeconds: 2)
        }

        let service: NetworkService = DefaultNetworkService(provider: provider)
        container.register(service: service)
    }
}

var ServerURL: URL {
    var urlString: String
    
    switch BuildSettings.shared.networkState {
    case .Test:
        urlString = "https://ucexvyy1j5.api.quickmocker.com"
    case .Prod, .Local:
        urlString = "https://ift.gate1.spaymentsplus.ru/sdk-gateway/v1"
    }
    return URL(string: urlString)!
}

protocol NetworkService: AnyObject {
    func request(_ target: TargetType, retryCount: Int, completion: @escaping (Result<Void, SDKError>) -> Void)
    func request<T>(_ target: TargetType, to: T.Type, retryCount: Int, completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable
    func cancelTask()
}

extension NetworkService {
    func request(_ target: TargetType, retryCount: Int = 1, completion: @escaping (Result<Void, SDKError>) -> Void) {
        request(target, retryCount: retryCount, completion: completion)
    }
    func request<T>(_ target: TargetType, to: T.Type, retryCount: Int = 1, completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable {
        request(target, to: to, retryCount: retryCount, completion: completion)
    }
}

final class DefaultNetworkService: NetworkService, ResponseDecoder {
    
    private let provider: NetworkProvider
    
    init(provider: NetworkProvider) {
        self.provider = provider
    }

    func request(_ target: TargetType, retryCount: Int = 1, completion: @escaping (Result<Void, SDKError>) -> Void) {
        provider.request(target, retryCount: retryCount) { data, response, error in
            SBLogger.logRequestCompleted(target, response: response, data: data)
            let result = self.decodeResponse(data: data, response: response, error: error)
            completion(result)
        }
    }
    
    func request<T>(_ target: TargetType, to: T.Type, retryCount: Int = 1, completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable {
        provider.request(target, retryCount: retryCount) { data, response, error in
            SBLogger.logRequestCompleted(target, response: response, data: data)
            let result = self.decodeResponse(data: data, response: response, error: error, type: to)
            completion(result)
        }
    }
    
    func cancelTask() {
        provider.cancel()
    }
}
