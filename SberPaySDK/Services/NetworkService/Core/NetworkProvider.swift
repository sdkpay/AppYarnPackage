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
    func request(_ target: TargetType, retryCount: Int, completion: @escaping NetworkProviderCompletion)
    func cancel()
}

final class DefaultNetworkProvider: NSObject, NetworkProvider {
    private var task: URLSessionTask?
    private var session: URLSession?
    private var requestManager: BaseRequestManager
     
    private lazy var certificate: Data? = {
        guard let fileDer = Bundle(for: SBPay.self).path(forResource: "ecomtest.sberbank.ru",
                                                         ofType: "der")
        else { return nil }
        return NSData(contentsOfFile: fileDer) as? Data
    }()
    
    init(requestManager: BaseRequestManager) {
        self.requestManager = requestManager
        super.init()
        session = URLSession(configuration: .default,
                             delegate: self,
                             delegateQueue: nil)
    }
    
    func request(_ target: TargetType,
                 retryCount: Int = 1,
                 completion: @escaping NetworkProviderCompletion) {
        _request(target: target, retryCount: retryCount, completion: completion)
    }

    private func _request(retry: Int = 1,
                          target: TargetType,
                          retryCount: Int,
                          completion: @escaping NetworkProviderCompletion) {
        do {
            let request = try self.buildRequest(from: target)
            SBLogger.logRequestStarted(request)
            task = session?.dataTask(with: request, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    if let response = response {
                        self.saveGeobalancingData(from: response)
                    }

                    if retryCount != 1,
                       let error = error,
                       error._code == -1001,
                       retry < 4 {
                        self._request(retry: retry + 1,
                                      target: target,
                                      retryCount: retryCount,
                                      completion: completion)
                    } else {
                        completion(data, response, error)
                    }
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
        task?.cancel()
    }

    private func buildRequest(from route: TargetType) throws -> URLRequest {
        var request = URLRequest(url: ServerURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20.0)
        request.httpMethod = route.httpMethod.rawValue
        switch route.task {
        case .request:
            addHeaders(request: &request, headers: nil)
        case let .requestWithParameters(urlParameters, bodyParameters):
            addHeaders(request: &request, headers: nil)
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
        var baseHeaders = HTTPHeaders()
        baseHeaders[String.Headers.rqUID] = String.generateRandom(with: 32)
        baseHeaders[String.Headers.localTime] = "\(Date())"

        for head in requestManager.headers {
            baseHeaders[head.key] = head.value
        }
        if let headers = headers {
            for head in headers {
                baseHeaders[head.key] = head.value
            }
        }
        for (name, value) in baseHeaders {
            request.setValue(value, forHTTPHeaderField: name)
        }
    }
    
    private func saveGeobalancingData(from response: URLResponse) {
        guard let response = response as? HTTPURLResponse else { return }
        let headers = response.allHeaderFields
        requestManager.cookie = headers[String.Headers.setCookie] as? String
        requestManager.pod = headers[String.Headers.pod] as? String
    }
}

// MARK: - Ssl pinning

extension DefaultNetworkProvider: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if !BuildSettings.shared.ssl {
            completionHandler(.performDefaultHandling, nil)
            return
        }
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
