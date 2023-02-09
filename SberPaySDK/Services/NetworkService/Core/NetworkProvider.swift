//
//  NetworkProvider.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

typealias NetworkProviderCompletion = (_ data: Data?,
                                       _ response: URLResponse?,
                                       _ error: Error?) -> Void
typealias HTTPHeaders = [String: String]

// MARK: - TargetType

protocol TargetType {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var sampleData: Data? { get }
}

// MARK: - HTTPMethod

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

// MARK: - HTTPTask

enum HTTPTask {
    case request
    case requestWithParameters(_ urlParameters: NetworkParameters? = nil,
                               bodyParameters: NetworkParameters? = nil)
    case requestWithParametersAndHeaders(_ urlParameters: NetworkParameters? = nil,
                                         bodyParameters: NetworkParameters? = nil,
                                         headers: HTTPHeaders? = nil)
}

// MARK: - NetworkProvider
protocol NetworkProvider {
    func request(_ route: TargetType, completion: @escaping NetworkProviderCompletion)
    func cancel()
}

final class DefaultNetworkProvider: NSObject, NetworkProvider {
    private var task: URLSessionTask?
    private var session: URLSession?
    private var requestManager: AuthRequestManager
     
    private lazy var certificate: Data? = {
        guard let fileDer = Bundle(for: SBPay.self).path(forResource: "ecomtest.sberbank.ru",
                                                         ofType: "der")
        else { return nil }
        return NSData(contentsOfFile: fileDer) as? Data
    }()
    
    init(requestManager: AuthRequestManager) {
        self.requestManager = requestManager
        super.init()
        session = URLSession(configuration: .default,
                             delegate: self,
                             delegateQueue: nil)
    }
    
    func request(_ route: TargetType, completion: @escaping NetworkProviderCompletion) {
        do {
            let request = try self.buildRequest(from: route)
            SBLogger.logRequestStarted(request)
            task = session?.dataTask(with: request, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            })
        } catch {
            DispatchQueue.main.async {
                completion(nil, nil, error)
            }
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    private func buildRequest(from route: TargetType) throws -> URLRequest {
        var request = URLRequest(url: ServerURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 90.0)
        request.httpMethod = route.httpMethod.rawValue
        switch route.task {
        case .request:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case let .requestWithParameters(urlParameters, bodyParameters):
            try configureParameters(request: &request, bodyParameters: bodyParameters, urlParameters: urlParameters)
        case let .requestWithParametersAndHeaders(urlParameters, bodyParameters, headers):
            addHeaders(request: &request, headers: headers)
            try configureParameters(request: &request, bodyParameters: bodyParameters, urlParameters: urlParameters)
        }
        return request
    }
    
    private func configureParameters(request: inout URLRequest,
                                     bodyParameters: NetworkParameters?,
                                     urlParameters: NetworkParameters?) throws {
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    private func addHeaders(request: inout URLRequest, headers: HTTPHeaders?) {
        guard let headers = headers else { return }
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
    }
}

// MARK: - Ssl pinning

extension DefaultNetworkProvider: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                    let serverCertificateData = SecCertificateCopyData(serverCertificate)
                    let data = CFDataGetBytePtr(serverCertificateData)
                    let size = CFDataGetLength(serverCertificateData)
                    let certFromHost = NSData(bytes: data, length: size)
                    if let localCert = certificate,
                       certFromHost.isEqual(to: localCert) {
                        completionHandler(.useCredential,
                                          URLCredential(trust: serverTrust))
                        return
                    } else {
                        completionHandler(.cancelAuthenticationChallenge, nil)
                        return
                    }
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
