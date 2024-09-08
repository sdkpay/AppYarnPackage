//
//  SeamlessAuthService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.11.2023.
//

import Foundation
import WebKit

final class SeamlessAuthServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(SeamlessAuthService.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: SeamlessAuthService = DefaultSeamlessAuthService(network: container.resolve(),
                                                                          sdkManager: container.resolve(),
                                                                          analytics: container.resolve(),
                                                                          authManager: container.resolve(),
                                                                          storage: container.resolve(), hostManager: container.resolve(),
                                                                          featureToggleService: container.resolve())
            return service
        }
    }
}

protocol SeamlessAuthService {
    var isReadyForSeamless: Bool { get }
    func getTransitTokenUrl() async throws -> URL
    func isValideAuth(from url: URL) throws -> Bool
}

final class DefaultSeamlessAuthService: NSObject, SeamlessAuthService {

    private let network: NetworkService
    private let sdkManager: SDKManager
    private let analytics: AnalyticsService
    private var authManager: AuthManager
    private let storage: KeychainStorage
    private let featureToggleService: FeatureToggleService
    private let hostManager: HostManager

    private var token: AppTokenDataModel?

    init(network: NetworkService,
         sdkManager: SDKManager,
         analytics: AnalyticsService,
         authManager: AuthManager,
         storage: KeychainStorage,
         hostManager: HostManager,
         featureToggleService: FeatureToggleService) {
        self.analytics = analytics
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        self.storage = storage
        self.hostManager = hostManager
        self.featureToggleService = featureToggleService
        super.init()
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    var isReadyForSeamless: Bool {
        
        let appToken = try? storage.get(for: .appToken,
                                              mode: .sid,
                                              to: AppTokenDataModel.self)
        return appToken != nil
    }
    
    func getTransitTokenUrl() async throws -> URL {
        
        guard let token = token?.appToken else { throw SDKError(.noData) }
        guard let clientId = authManager.authModel?.clientId else { throw SDKError(.noData) }
        guard let redirectUri = sdkManager.authInfo?.redirectUri else { throw SDKError(.noData) }
        
        let exchangeToken = try await network.request(AuthTarget.tokenExchange(token: token,
                                                                               resource: redirectUri,
                                                                               clientId: clientId),
                                                      to: ExchangeTokenModel.self,
                                                      host: .sid)
        
        return try getOidcUrl(token: exchangeToken.accessToken)
    }
    
    private func getOidcUrl(token: String) throws -> URL {
        
        var components = URLComponents(url: hostManager.host(for: .sid), resolvingAgainstBaseURL: true)
        
        components?.path = "/CSAFront/oidc/authorize.do"
        
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: authManager.authModel?.clientId),
            URLQueryItem(name: "scope", value: authManager.authModel?.scope),
            URLQueryItem(name: "code_challenge_method", value: authManager.authModel?.codeChallengeMethod),
            URLQueryItem(name: "code_challenge", value: authManager.authModel?.codeChallengeMethod),
            URLQueryItem(name: "redirect_uri", value: sdkManager.authInfo?.redirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "token", value: token)
        ]
        
        guard let url = components?.url else { throw SDKError(.noData) }

        SBLogger.log("🔗 Sid auth url: \(url.absoluteString)")
        
        return url
    }
    
    func isValideAuth(from url: URL) throws -> Bool {
        
        guard let redirectUri = sdkManager.authInfo?.redirectUri else { throw SDKError(.noData) }
        
        guard let redirectUriURL = URL(string: redirectUri) else { throw SDKError(.noData) }
                                                                                        
        guard url.scheme == redirectUriURL.scheme else { return false }
        
        guard let  urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
        
        guard let queryItems = urlComponents.queryItems else { return false }
        
        var parameters = [String: String]()
        queryItems.forEach {
            if let value = $0.value {
                parameters[$0.name] = value
            }
        }
        
        guard let code = parameters["code"] else { return false }
        
        authManager.authCode = code
        
        return true
    }
}

struct AppTokenDataModel: Codable {
    
    enum AuthType: String {
        
        case app2app
        case oidc2app
        case app2web
    }
    
    var appToken: String?
    var dateOfRecieving: Double
    var authType: String?
    
    var authTypeEnum: AuthType? {
        
        guard let authType else { return nil }
        return AuthType(rawValue: authType)
    }
}

extension DefaultSeamlessAuthService: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            CertificateValidator.validate(defaultHandling: false,
                                          challenge: challenge,
                                          completionHandler: completionHandler)
        }
    }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return }
            
            SBLogger.log("🔗 Sid go to: \(url.absoluteString)")
            decisionHandler(.allow)
        }
}
