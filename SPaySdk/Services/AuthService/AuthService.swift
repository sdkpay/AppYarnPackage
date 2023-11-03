//
//  AuthService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class AuthServiceAssembly: Assembly {
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
                                                          buildSettings: container.resolve())
            return service
        }
    }
}

protocol AuthService {
    func auth(completion: @escaping (Result<Void, SDKError>) -> Void)
    func tryToGetSessionId(completion: @escaping (Result<AuthMethod, SDKError>) -> Void)
    func appAuth(completion: @escaping (Result<Void, SDKError>) -> Void)
    func completeAuth(with url: URL)
    var tokenInStorage: Bool { get }
    var bankCheck: Bool { get set }
}

final class DefaultAuthService: AuthService, ResponseDecoder {
    
    private enum AuthRequestType {
        case auth
        case sessionId
    }
    
    private var authСompletion: ((SDKError?, Bool) -> Void)?
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
    private var appCompletion: ((Result<Void, SDKError>) -> Void)?
    private var appLink: String?
    
    var bankCheck = false
    
    var tokenInStorage: Bool {
        if self.buildSettings.refresh {
            return (try? storage.exists(.cookieId)) ?? false
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
         buildSettings: BuildSettings) {
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
        self.featureToggleService = featureToggleService
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func tryToGetSessionId(completion: @escaping (Result<AuthMethod, SDKError>) -> Void) {
        personalMetricsService.getIp { [weak self] ip in
            self?.authManager.ipAddress = ip
            // Проверка на целостность
            if self?.enviromentManager.environment != .prod {
                self?.getSessionId(completion: completion)
            } else {
                self?.personalMetricsService.integrityCheck { [weak self] result in
                    switch result {
                    case true:
                        self?.getSessionId(completion: completion)
                    case false:
                        completion(.failure(.personalInfo))
                    }
                }
            }
        }
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
            authСompletion?(nil, false)
            appCompletion?(.success)
        case .failure(let error):
            authСompletion?(error, false)
            appCompletion?(.failure(error))
        }
        authСompletion = nil
        appCompletion = nil
    }
    
    private func fillFakeData() {
        authManager.authCode = "3401216B-8B70-21FA-2592-58010E53EE5B"
        authСompletion?(nil, true)
    }
    
    private func addFrontHeaders() {
        baseRequestManager.generateB3Cookie()
    }
    
    private func getSessionId(completion: @escaping (Result<AuthMethod, SDKError>) -> Void) {
        guard let request = sdkManager.authInfo else { return }
        addFrontHeaders()
        analytics.sendEvent(.RQSessionId,
                            with: [.view: AnlyticsScreenEvent.AuthVC.rawValue])
        network.request(AuthTarget.getSessionId(redirectUri: request.redirectUri,
                                                merchantLogin: request.merchantLogin,
                                                orderId: request.orderId,
                                                amount: request.amount,
                                                currency: request.currency,
                                                orderNumber: request.orderNumber,
                                                expiry: request.expiry,
                                                frequency: request.frequency,
                                                authCookie: getRefreshCookies()),
                        to: AuthModel.self) { [weak self] result in
            switch result {
            case .success(let result):
                guard let self = self else { return }
                self.analytics.sendEvent(.RQGoodSessionId,
                                         with: [AnalyticsKey.view: AnlyticsScreenEvent.AuthVC.rawValue])
                self.authManager.sessionId = result.sessionId
                self.appLink = result.deeplink
                self.partPayService.setEnabledBnpl(result.isBnplEnabled ?? false, enabledLevel: .session)
                
                let refreshIsActive = result.refreshTokenIsActive ?? false

                let event: AnalyticsEvent = refreshIsActive ? .STGetGoodRefresh : .STGetFailRefresh
                self.analytics.sendEvent(event)
                
                if refreshIsActive && self.featureToggleService.isEnabled(.refresh) && self.cookieStorage.exists(.refreshData) {
                    self.authManager.authMethod = .refresh
                } else {
                    self.authManager.authMethod = .bank
                }
                completion(.success(self.authManager.authMethod ?? .bank))
            case .failure(let error):
                self?.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                     type: .auth(type: .sessionId))
                completion(.failure(error))
            }
        }
    }
    
    func appAuth(completion: @escaping (Result<Void, SDKError>) -> Void) {
        self.authManager.authMethod = .bank
        self.appCompletion = completion
        sIdAuth()
    }
    
    // MARK: - Методы авторизации через sId
    private func sIdAuth() {
        let target = enviromentManager.environment == .sandboxWithoutBankApp
        guard !target else {
            fillFakeData()
            return
        }
        
        guard let appLink,
              let link = authURL(link: appLink) else {
            appCompletion?(.failure(.noData))
            appCompletion = nil
            return
        }
        
        UIApplication.shared.open(link) { [weak self] success in
            if !success {
                SBLogger.log("🏦 Bank app not found")
                self?.appCompletion?(.failure(.bankAppNotFound))
                self?.appCompletion = nil
                return
            }
        }
        SBLogger.logRequestToSbolStarted(link)
    }
    
    private func authURL(link: String) -> URL? {
        guard let url = bankAppManager.selectedBank?.link else { return nil }
        return URL(string: url + link)
    }
    
    func auth(completion: @escaping (Result<Void, SDKError>) -> Void) {
        personalMetricsService.getUserData { [weak self] data in
            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(.personalInfo))
                }
                return
            }
            
            self?.authMethod(deviceInfo: data, completion: completion)
        }
    }
    
    private func authMethod(deviceInfo: String, completion: @escaping (Result<Void, SDKError>) -> Void) {
        guard let request = sdkManager.authInfo else { return }
        analytics.sendEvent(.RQAuth,
                            with: [AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue])
        network.requestFull(AuthTarget.auth(redirectUri: authManager.authMethod == .bank ? request.redirectUri : nil,
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
                                            resourceName: Bundle.main.displayName ?? "None",
                                            authCookie: getRefreshCookies()),
                            to: AuthRefreshModel.self) { [weak self] result in
            switch result {
            case .success(let authModel):
                self?.saveRefreshIfNeeded(from: authModel.cookies)
                self?.authManager.userInfo = authModel.result.userInfo
                self?.authManager.isOtpNeed = authModel.result.isOtpNeed
                self?.analytics.sendEvent(.RSGoodAuth,
                                          with: [AnalyticsKey.view: AnlyticsScreenEvent.None.rawValue])
                completion(.success)
            case .failure(let error):
                guard let self else { return }
                self.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                    type: .auth(type: .auth))
                
                if self.authManager.authMethod == .bank {
                    completion(.failure(error))
                    return
                }

                self.appAuth { result in
                    switch result {
                    case .success:
                        self.auth(completion: completion)
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            }
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
}
