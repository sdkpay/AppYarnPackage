//
//  AuthService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit
import Combine

final class AuthServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(AuthService.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: AuthService = DefaultAuthService(network: container.resolve(),
                                                          sdkManager: container.resolve(),
                                                          analytics: container.resolve(),
                                                          bankAppManager: container.resolve(),
                                                          authManager: container.resolve(),
                                                          partPayService: container.resolve(),
                                                          storage: container.resolve(),
                                                          baseRequestManager: container.resolve(),
                                                          personalMetricsService: container.resolve(),
                                                          enviromentManager: container.resolve(),
                                                          cookieStorage: container.resolve(),
                                                          featureToggleService: container.resolve(),
                                                          buildSettings: container.resolve(),
                                                          seamlessAuthService: container.resolve())
            return service
        }
    }
}

private extension MetricsValue {
    
    static let refresh = MetricsValue(rawValue: "Refresh")
    static let bankAppAuth = MetricsValue(rawValue: "BankAppAuth")
}

private enum Constants {
    
    static let sendboxAuthCode = "3401216B-8B70-21FA-2592-58010E53EE5B"
}

protocol AuthService {
    func auth() async throws
    func tryToGetSessionId() async throws -> AuthMethod
    func appAuth() async throws
    func revokeToken() async throws
    func completeAuth(with url: URL)
    var tokenInStorage: Bool { get }
    var bankCheck: Bool { get set }
}

final class DefaultAuthService: AuthService, ResponseDecoder {
    
    private enum AuthRequestType {
        case auth
        case sessionId
    }
    
    private var analytics: AnalyticsManager
    private let network: NetworkService
    private let sdkManager: SDKManager
    private var bankAppManager: BankAppManager
    private var authManager: AuthManager
    private var buildSettings: BuildSettings
    private var partPayService: PartPayService
    private var personalMetricsService: PersonalMetricsService
    private var enviromentManager: EnvironmentManager
    private let featureToggleService: FeatureToggleService
    private var storage: KeychainStorage
    private var baseRequestManager: BaseRequestManager
    private var cookieStorage: CookieStorage
    private let seamlessAuthService: SeamlessAuthService
    private var appAuthCompletion: ((Result<Void, SDKError>) -> Void)?
    private var appLink: String?
    
    private var cancellable: Cancellable?
    
    var bankCheck = false
    
    var tokenInStorage: Bool {
        if self.buildSettings.refresh, buildSettings.networkState == .Local {
            return true
        }
        if self.buildSettings.refresh {
            return cookieStorage.exists(.id) && cookieStorage.exists(.refreshData)
        } else {
            return false
        }
    }
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         analytics: AnalyticsManager,
         bankAppManager: BankAppManager,
         authManager: AuthManager,
         partPayService: PartPayService,
         storage: KeychainStorage,
         baseRequestManager: BaseRequestManager,
         personalMetricsService: PersonalMetricsService,
         enviromentManager: EnvironmentManager,
         cookieStorage: CookieStorage,
         featureToggleService: FeatureToggleService,
         buildSettings: BuildSettings,
         seamlessAuthService: SeamlessAuthService) {
        self.analytics = analytics
        self.network = network
        self.sdkManager = sdkManager
        self.bankAppManager = bankAppManager
        self.authManager = authManager
        self.baseRequestManager = baseRequestManager
        self.partPayService = partPayService
        self.personalMetricsService = personalMetricsService
        self.enviromentManager = enviromentManager
        self.buildSettings = buildSettings
        self.storage = storage
        self.cookieStorage = cookieStorage
        self.seamlessAuthService = seamlessAuthService
        self.featureToggleService = featureToggleService
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func tryToGetSessionId() async throws -> AuthMethod {
        
        let ipAddress = await personalMetricsService.getIp()
        self.authManager.ipAddress = ipAddress
        
#if SDKPROD
        if enviromentManager.environment == .prod {
            try await personalMetricsService.integrityCheck()
        }
#endif
        return try await getSessionId()
    }
    
    func completeAuth(with url: URL) {
        // Сохраняем выбранный банк если произошел успешный редирект обратно в приложение
        SBLogger.log("🏦 Bank app get url \(url.absoluteString)")
        bankAppManager.saveSelectedBank()
        SBLogger.log("🏦 Save selected bank")
        switch decodeParametersFrom(url: url) {
        case .success(let result):
            
            if let code = result.code,
               let state = result.state {
                authManager.authCode = code
                authManager.state = state
            } else {
                analytics.send(EventBuilder()
                    .with(base: .LC)
                    .with(value: .bankAppAuth)
                    .with(postState: .Fail)
                    .with(value: MetricsValue(rawValue: url.absoluteString))
                    .build())
                
                appAuthCompletion?(.failure(.init(.bankAppError)))
                return
            }
            
            analytics.send(EventBuilder()
                .with(base: .LC)
                .with(value: .bankAppAuth)
                .with(postState: .Good)
                .build())
            
            appAuthCompletion?(.success)
        case .failure(let error):
            
            analytics.send(EventBuilder()
                .with(base: .LC)
                .with(value: .bankAppAuth)
                .with(postState: .Fail)
                .with(value: MetricsValue(rawValue: url.absoluteString))
                .build())
            
            appAuthCompletion?(.failure(error))
        }
        appAuthCompletion = nil
    }
    
    private func addFrontHeaders() {
        
        baseRequestManager.generateB3Cookie()
    }
    
    private func getSessionId() async throws -> AuthMethod {
        
        guard let request = sdkManager.authInfo else {
            throw SDKError(.noData)
        }
    
        addFrontHeaders()
        
        do {
            let sessionIdResult = try await network.request(AuthTarget.getSessionId(redirectUri: request.redirectUri,
                                                                                    merchantLogin: request.merchantLogin,
                                                                                    orderId: request.orderId,
                                                                                    amount: request.amount,
                                                                                    currency: request.currency,
                                                                                    orderNumber: request.orderNumber,
                                                                                    expiry: request.expiry,
                                                                                    frequency: request.frequency,
                                                                                    authCookie: getRefreshCookies()),
                                                            to: AuthModel.self)
            
            self.authManager.sessionId = sessionIdResult.sessionId
            self.authManager.authModel = sessionIdResult
            self.authManager.state = sessionIdResult.state
            self.appLink = sessionIdResult.deeplink
            self.partPayService.setEnabledBnpl(sessionIdResult.isBnplEnabled ?? false, enabledLevel: .session)
            
            let refreshIsActive = sessionIdResult.refreshTokenIsActive ?? false
            
            if refreshIsActive
                && featureToggleService.isEnabled(.refresh)
                && sdkManager.payStrategy != .partPay
                && sdkManager.payStrategy != .withoutRefresh
                && tokenInStorage {
                
                self.authManager.authMethod = .refresh
            } else if seamlessAuthService.isReadyForSeamless {
                
                self.authManager.authMethod = .sid
            } else {
                
                self.authManager.authMethod = .bank
            }
            
            return self.authManager.authMethod ?? .bank
        } catch {
            throw error
        }
    }
    
    @MainActor
    func appAuth() async throws {
        
        SBLogger.logThread(obj: self)
        
        self.authManager.authMethod = .bank
        
        analytics.send(EventBuilder()
            .with(base: .LC)
            .with(value: .bankAppAuth)
            .build())
        try await sIdAuth()
    }

    @MainActor
    private func sIdAuth() async throws {
        
        SBLogger.logThread(obj: self)
        
        guard let appLink,
              let link = authURL(link: appLink) else {
            throw SDKError(.noData)
        }
        
       SBLogger.logRequestToSbolStarted(link)
        
        addOnScreenNotification()
        
       let result = await UIApplication.shared.open(link)
        
        switch result {
        case true:
            
            try await withCheckedThrowingContinuation { continuation in
                
                var nillableContinuation: CheckedContinuation<Void, Error>? = continuation
                
                self.appAuthCompletion = { result in
                    switch result {
                    case .success:
                        self.removeOnScreenNotification()
                        nillableContinuation?.resume()
                        nillableContinuation = nil
                    case .failure(let error):
                        self.removeOnScreenNotification()
                        nillableContinuation?.resume(throwing: error)
                        nillableContinuation = nil
                    }
                }
            }
  
        case false:
            removeOnScreenNotification()
            throw SDKError(.bankAppNotFound)
        }
    }
    
    private func authURL(link: String) -> URL? {
        
        guard let url = bankAppManager.selectedBank?.authLink else { return nil }
        return URL(string: url + link)
    }
    
    func auth() async throws {
        
        let userData = try await personalMetricsService.getUserData()
        try await authMethod(deviceInfo: userData)
    }
    
    func revokeToken() async throws {
        do {
            try await network.request(
                AuthTarget.revokeToken(authCookie: getRefreshCookies())
            )
            cookieStorage.cleanCookie()
        } catch {
            throw error
        }
    }

    private func authMethod(deviceInfo: String) async throws {
        
        SBLogger.logThread(obj: self)
        
        guard let request = sdkManager.authInfo else {
            throw SDKError(.noData)
        }
        
        if enviromentManager.environment != .prod {
            
            authManager.authCode = Constants.sendboxAuthCode
        }
        
        do {
            
            let authResult = try await network.requestFull(AuthTarget.auth(redirectUri: authManager.authMethod == .bank ? request.redirectUri : nil,
                                                                           authCode: authManager.authMethod == .bank ? authManager.authCode : nil,
                                                                           sessionId: authManager.sessionId ?? "",
                                                                           state: authManager.authMethod == .bank ? authManager.state : nil,
                                                                           deviceInfo: deviceInfo,
                                                                           orderId: request.orderId,
                                                                           amount: request.amount,
                                                                           currency: request.currency,
                                                                           mobilePhone: nil,
                                                                           orderNumber: request.orderNumber,
                                                                           description: nil,
                                                                           expiry: request.expiry,
                                                                           frequency: request.frequency,
                                                                           userName: nil,
                                                                           merchantLogin: request.merchantLogin,
                                                                           resourceName: Bundle.main.bundleIdentifier ?? "no.info",
                                                                           authCookie: getRefreshCookies()),
                                                           to: AuthRefreshModel.self)
            
            saveRefreshIfNeeded(from: authResult.cookies)
            authManager.userInfo = authResult.result.userInfo
            authManager.isOtpNeed = authResult.result.isOtpNeed
        } catch {
            throw error
        }
    }
    
    private func saveRefreshIfNeeded(from cookies: [HTTPCookie]) {
        
        if let idCookie = cookies.first(where: { $0.name == Cookies.id.rawValue }) {
            cookieStorage.setCookie(cookie: idCookie, for: .id)
        }
        
        if let dataCookie = cookies.first(where: { $0.name == Cookies.refreshData.rawValue }) {
            cookieStorage.setCookie(cookie: dataCookie, for: .refreshData)
            
            analytics.send(EventBuilder()
                .with(base: .ST)
                .with(action: .Save)
                .with(value: .refresh)
                .build())
        }
    }
        
    private func getRefreshCookies() -> [HTTPCookie] {
        
        guard sdkManager.payStrategy == .auto || sdkManager.payStrategy == .manual else { return [] }
        
        var cookies = [HTTPCookie]()
        
        if let idCookie = cookieStorage.getCookie(for: .id) {
            cookies.append(idCookie)
        }
        if let cookieData = cookieStorage.getCookie(for: .refreshData) {
            cookies.append(cookieData)
        }
        
        let event = EventBuilder().with(base: .ST).with(action: .Get).with(value: .refresh)
        
        if cookies.isEmpty {
            event.with(state: .Fail)
        } else {
            event.with(state: .Good)   
        }
        
        analytics.send(event.build())
        return cookies
    }
    
    private func getIdCookies() -> [HTTPCookie] {
        
        if let idCookies = cookieStorage.getCookie(for: .id) {
            return [idCookies]
        } else {
            return []
        }
    }
    
    private func addOnScreenNotification() {
    
        cancellable = NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                
                self.analytics.send(EventBuilder()
                    .with(base: .LC)
                    .with(value: .bankAppAuth)
                    .with(postState: .Fail)
                    .build())
                self.bankAppManager.selectedBank = nil
                self.appAuthCompletion?(.failure(SDKError(.bankAppError)))
        }
    }
    
    private func removeOnScreenNotification() {
        cancellable?.cancel()
    }
}
