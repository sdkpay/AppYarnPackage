//
//  NetworkService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import UIKit

final class NetworkServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let provider: NetworkProvider = BuildSettings.needStubs ?
        StubNetworkProvider(delayedSeconds: 2) : DefaultNetworkProvider(requestManager: container.resolve())
        let service: NetworkService = DefaultNetworkService(provider: provider)
        container.register(service: service)
    }
}

var ServerURL: URL {
    let urlString = "https://app5.kurochkinas.ru/"
    return URL(string: urlString)!
}

protocol NetworkService: AnyObject {
    func request(_ target: TargetType, completion: @escaping (Result<Void, SDKError>) -> Void)
    func request<T>(_ target: TargetType, to: T.Type, completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable
    func cancelTask()
}

final class DefaultNetworkService: NetworkService, ResponseDecoder {
    private let provider: NetworkProvider
    
    init(provider: NetworkProvider) {
        self.provider = provider
    }

    func request(_ target: TargetType, completion: @escaping (Result<Void, SDKError>) -> Void) {
        provider.request(target) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error)
            SBLogger.logRequestCompleted(target, response: response, data: data)
            completion(result)
        }
    }
    
    func request<T>(_ target: TargetType, to: T.Type, completion: @escaping (Result<T, SDKError>) -> Void) where T: Codable {
        provider.request(target) { data, response, error in
            let result = self.decodeResponse(data: data, response: response, error: error, type: to)
            SBLogger.logRequestCompleted(target, response: response, data: data)
            completion(result)
        }
    }
    
    func cancelTask() {
        provider.cancel()
    }
}
