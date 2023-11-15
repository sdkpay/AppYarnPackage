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
        
        let service: NetworkService = DefaultNetworkService(provider: provider)
        container.register(service: service)
    }
}

protocol NetworkService: AnyObject {
    
    func request(_ target: TargetType,
                 host: HostSettings,
                 retrySettings: RetrySettings) async throws
    
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    host: HostSettings,
                    retrySettings: RetrySettings) async throws -> T where T: Codable
     
    func requestString(_ target: TargetType,
                       host: HostSettings,
                       retrySettings: RetrySettings) async throws -> String
    
    func requestFull<T>(_ target: TargetType,
                        to: T.Type,
                        host: HostSettings,
                        retrySettings: RetrySettings) async throws -> (result: T,
                                                                       headers: HTTPHeaders,
                                                                       cookies: [HTTPCookie]) where T: Codable
    func cancelTask()
}

extension NetworkService {
    
    func request(_ target: TargetType,
                 host: HostSettings = .main,
                 retrySettings: RetrySettings = (1, [])) async throws {
        try await request(target, host: host, retrySettings: retrySettings)
    }
    
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    host: HostSettings = .main,
                    retrySettings: RetrySettings = (1, [])) async throws -> T where T: Codable {
        try await request(target, to: to, host: host, retrySettings: retrySettings)
    }
    
    func requestString(_ target: TargetType,
                       host: HostSettings = .main,
                       retrySettings: RetrySettings = (1, [])) async throws -> String {
        try await requestString(target, host: host, retrySettings: retrySettings)
    }
    
    @discardableResult
    func requestFull<T>(_ target: TargetType,
                        to: T.Type,
                        host: HostSettings = .main,
                        retrySettings: RetrySettings = (1, [])) async throws -> (result: T,
                                                                                 headers: HTTPHeaders,
                                                                                 cookies: [HTTPCookie]) where T: Codable {
        try await requestFull(target, to: to, host: host, retrySettings: retrySettings)
    }
}

final class DefaultNetworkService: NetworkService, ResponseDecoder {
    
    private let provider: NetworkProvider
    
    init(provider: NetworkProvider) {
        self.provider = provider
    }
    
    func request(_ target: TargetType,
                 host: HostSettings,
                 retrySettings: RetrySettings = (1, [])) async throws {
        
        do {
            let result = try await provider.request(target, retrySettings: retrySettings, host: host)
            return try self.decodeResponse(data: result.data, response: result.response)
        } catch {
            throw self.systemError(error)
        }
    }
    
    func request<T>(_ target: TargetType,
                    to: T.Type,
                    host: HostSettings,
                    retrySettings: RetrySettings = (1, [])) async throws -> T where T: Codable {
        
        do {
            let result = try await provider.request(target, retrySettings: retrySettings, host: host)
            return try self.decodeResponse(data: result.data, response: result.response, type: to)
        } catch {
            throw self.systemError(error)
        }
    }
    
    func requestString(_ target: TargetType,
                       host: HostSettings = .main,
                       retrySettings: RetrySettings = (1, [])) async throws -> String {
        do {
            let result = try await provider.request(target, retrySettings: retrySettings, host: host)
            return try self.decodeResponse(data: result.data, response: result.response, type: String.self)
        } catch {
            throw self.systemError(error)
        }
    }
    
    func requestFull<T>(_ target: TargetType,
                        to: T.Type,
                        host: HostSettings,
                        retrySettings: RetrySettings = (1, [])) async throws -> (result: T,
                                                                                 headers: HTTPHeaders,
                                                                                 cookies: [HTTPCookie]) where T: Codable {
        
        do {
            let result = try await provider.request(target, retrySettings: retrySettings, host: host)
            return try self.decodeResponseFull(data: result.data, response: result.response, type: to)
        } catch {
            throw self.systemError(error)
        }
    }
    
    func cancelTask() {
        provider.cancel()
    }
}
