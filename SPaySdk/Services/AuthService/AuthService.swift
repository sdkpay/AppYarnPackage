//
//  AuthService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

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
                                                          parsingErrorAnaliticManager: container.resolve(),
                                                          featureToggleService: container.resolve(),
                                                          buildSettings: container.resolve(),
                                                          seamlessAuthService: container.resolve())
            return service
        }
    }
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
    
    private var analytics: AnalyticsService
    private let network: NetworkService
    private let sdkManager: SDKManager
    private let bankAppManager: BankAppManager
    private var authManager: AuthManager
    private var buildSettings: BuildSettings
    private var partPayService: PartPayService
    private var personalMetricsService: PersonalMetricsService
    private var enviromentManager: EnvironmentManager
    private let featureToggleService: FeatureToggleService
    private var storage: KeychainStorage
    private var baseRequestManager: BaseRequestManager
    private var cookieStorage: CookieStorage
    private let parsingErrorAnaliticManager: ParsingErrorAnaliticManager
    private let seamlessAuthService: SeamlessAuthService
    private var appAuthCompletion: ((Result<Void, SDKError>) -> Void)?
    private var appLink: String?
    
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
         analytics: AnalyticsService,
         bankAppManager: BankAppManager,
         authManager: AuthManager,
         partPayService: PartPayService,
         storage: KeychainStorage,
         baseRequestManager: BaseRequestManager,
         personalMetricsService: PersonalMetricsService,
         enviromentManager: EnvironmentManager,
         cookieStorage: CookieStorage,
         parsingErrorAnaliticManager: ParsingErrorAnaliticManager,
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
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func tryToGetSessionId() async throws -> AuthMethod {
        
        let ipAddress = await personalMetricsService.getIp()
        self.authManager.ipAddress = ipAddress
        
        if enviromentManager.environment == .prod {
            try await personalMetricsService.integrityCheck()
        }
        
        return try await getSessionId()
    }
    
    func completeAuth(with url: URL) {
        // Сохраняем выбранный банк если произошел успешный редирект обратно в приложение
        SBLogger.log("🏦 Bank app get url \(url.absoluteString)")
        bankAppManager.saveSelectedBank()
        SBLogger.log("🏦 Save selected bank")
        switch decodeParametersFrom(url: url) {
        case .success(let result):
            authManager.authCode = result.code
            authManager.state = result.state
            appAuthCompletion?(.success)
        case .failure(let error):
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
        analytics.sendEvent(.RQSessionId,
                            with: [.view: AnlyticsScreenEvent.AuthVC.rawValue])
        
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
            
            self.analytics.sendEvent(.RQGoodSessionId,
                                     with: [AnalyticsKey.view: AnlyticsScreenEvent.AuthVC.rawValue])
            self.authManager.sessionId = sessionIdResult.sessionId
            self.authManager.authModel = sessionIdResult
            self.authManager.state = sessionIdResult.state
            self.appLink = sessionIdResult.deeplink
            self.partPayService.setEnabledBnpl(sessionIdResult.isBnplEnabled ?? false, enabledLevel: .session)
            
            let refreshIsActive = sessionIdResult.refreshTokenIsActive ?? false

            let event: AnalyticsEvent = refreshIsActive ? .STGetGoodRefresh : .STGetFailRefresh
            self.analytics.sendEvent(event)
            
            if refreshIsActive &&
                featureToggleService.isEnabled(.refresh) && tokenInStorage {
                self.authManager.authMethod = .refresh
            } else if seamlessAuthService.isReadyForSeamless() {
                self.authManager.authMethod = .sid
            } else {
                self.authManager.authMethod = .bank
            }
            
            return self.authManager.authMethod ?? .bank
        } catch {
            if let error = error as? SDKError {
                parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                               type: .auth(type: .sessionId))
            }
            throw error
        }
    }
    
    @MainActor
    func appAuth() async throws {
        SBLogger.logThread(obj: self)
        self.authManager.authMethod = .bank
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
        
       let result = await UIApplication.shared.open(link)
        
        switch result {
        case true:
            
            try await withCheckedThrowingContinuation({( inCont: CheckedContinuation<Void, Error>) -> Void in
                self.appAuthCompletion = { result in
                    switch result {
                    case .success:
                        inCont.resume()
                    case .failure(let error):
                        inCont.resume(throwing: error)
                    }
                }
            })
        case false:
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
        
        analytics.sendEvent(.RQAuth,
                            with: [AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue])
        
        if enviromentManager.environment != .prod {
            
            authManager.authCode = Constants.sendboxAuthCode
        }
        
        do {
            
            let authResult = try await network.requestFull(AuthTarget.auth(redirectUri: authManager.authMethod == .bank ? request.redirectUri : nil,
                                                                           authCode: authManager.authCode,
                                                                           sessionId: authManager.sessionId ?? "",
                                                                           state: authManager.state,
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
                                                                           resourceName: Bundle.main.displayName,
                                                                           authCookie: getRefreshCookies()),
                                                           to: AuthRefreshModel.self)
            
            saveRefreshIfNeeded(from: authResult.cookies)
            authManager.userInfo = authResult.result.userInfo
            authManager.isOtpNeed = authResult.result.isOtpNeed
            analytics.sendEvent(.RSGoodAuth,
                                with: [AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue])
        } catch {
            if let error = error as? SDKError {
                parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                               type: .auth(type: .sessionId))
            }
            
            if self.authManager.authMethod == .bank {
                throw error
            }
            throw error
        }
    }
    
    private func saveRefreshIfNeeded(from cookies: [HTTPCookie]) {
        
        if let idCookie = cookies.first(where: { $0.name == Cookies.id.rawValue }) {
            cookieStorage.setCookie(cookie: idCookie, for: .id)
        }
        
        if let dataCookie = cookies.first(where: { $0.name == Cookies.refreshData.rawValue }) {
            cookieStorage.setCookie(cookie: dataCookie, for: .refreshData)
        }
    }
        
    private func getRefreshCookies() -> [HTTPCookie] {
        
        var cookies = [HTTPCookie]()
        
        if let idCookie = cookieStorage.getCookie(for: .id) {
            cookies.append(idCookie)
        }
        if let cookieData = cookieStorage.getCookie(for: .refreshData) {
            cookies.append(cookieData)
        }
        return cookies
    }
    
    private func getIdCookies() -> [HTTPCookie] {
        if let idCookies = cookieStorage.getCookie(for: .id) {
            return [idCookies]
        } else {
            return []
        }
    }
}
