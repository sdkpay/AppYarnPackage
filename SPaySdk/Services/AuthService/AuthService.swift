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
                                                          personalMetricsService: container.resolve(),
                                                          enviromentManager: container.resolve(),
                                                          storage: container.resolve(),
                                                          buildSettings: container.resolve())
            return service
        }
    }
}

protocol AuthService {
    func tryToAuth(completion: @escaping (SDKError?, Bool) -> Void)
    func refreshAuth(completion: @escaping (Result<Void, SDKError>) -> Void)
    func appAuth(completion: @escaping (Result<Void, SDKError>) -> Void)
    func completeAuth(with url: URL)
    var tokenInStorage: Bool { get }
    var bankCheck: Bool { get set }
}

final class DefaultAuthService: AuthService, ResponseDecoder {
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
    private var storage: KeychainStorage
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
         personalMetricsService: PersonalMetricsService,
         enviromentManager: EnvironmentManager,
         storage: KeychainStorage,
         buildSettings: BuildSettings) {
        self.analytics = analytics
        self.network = network
        self.sdkManager = sdkManager
        self.bankAppManager = bankAppManager
        self.authManager = authManager
        self.partPayService = partPayService
        self.personalMetricsService = personalMetricsService
        self.enviromentManager = enviromentManager
        self.buildSettings = buildSettings
        self.storage = storage
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func tryToAuth(completion: @escaping (SDKError?, Bool) -> Void) {
        // Проверка на целостность
        if enviromentManager.environment != .prod {
            authRequest(completion: completion)
        } else {
            personalMetricsService.integrityCheck { [weak self] result in
                switch result {
                case true:
                    self?.authRequest(completion: completion)
                case false:
                    completion(.personalInfo, false)
                }
            }
        }
    }
    
    func completeAuth(with url: URL) {
        // Сохраняем выбранный банк если произошел успешный редирект обратно в приложение
        bankAppManager.saveSelectedBank()
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
    }
    
    private func fillFakeData() {
        authManager.authCode = "3401216B-8B70-21FA-2592-58010E53EE5B"
        authСompletion?(nil, true)
    }
    
    private func authRequest(method: AuthMethod? = nil,
                             completion: @escaping (SDKError?, Bool) -> Void) {
        guard let request = sdkManager.authInfo else { return }
        network.request(AuthTarget.getSessionId(redirectUri: request.redirectUri,
                                                merchantLogin: request.merchantLogin,
                                                orderId: request.orderId,
                                                amount: request.amount,
                                                currency: request.currency,
                                                orderNumber: request.orderNumber,
                                                expiry: request.expiry,
                                                frequency: request.frequency),
                        to: AuthModel.self) { [weak self] result in
            self?.authСompletion = completion
            switch result {
            case .success(let result):
                guard let self = self else { return }
                self.authManager.sessionId = result.sessionId
                self.authManager.state = result.state
                self.appLink = result.deeplink
                self.partPayService.setUserEnableBnpl(result.isBnplEnabled ?? false,
                                                      enabledLevel: .server)
                
                var refreshIsActive = false
                
                if self.buildSettings.networkState == .Local {
                    refreshIsActive = self.buildSettings.refresh
                } else {
                    refreshIsActive = result.refreshTokenIsActive ?? false
                }
                
                if refreshIsActive {
                    self.authManager.authMethod = .refresh
                    self.authСompletion?(nil, false)
                } else {
                    self.authManager.authMethod = .bank
                    self.sIdAuth()
                }
            case .failure(let error):
                completion(error, false)
            }
        }
    }
    
    func appAuth(completion: @escaping (Result<Void, SDKError>) -> Void) {
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
            return
        }
        UIApplication.shared.open(link) { [weak self] success in
            if !success {
                self?.analytics.sendEvent(.RedirectDenied)
            }
        }
        SBLogger.logRequestToSbolStarted(link)
    }
    
    private func authURL(link: String) -> URL? {
        guard let url = bankAppManager.selectedBank?.link else { return nil }
        return URL(string: url + link)
    }
    
    func refreshAuth(completion: @escaping (Result<Void, SDKError>) -> Void) {
        personalMetricsService.getUserData { [weak self] data in
            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(.personalInfo))
                }
                return
            }
            
            self?.auth(deviceInfo: data, completion: completion)
        }
    }
    
    private func auth(deviceInfo: String, completion: @escaping (Result<Void, SDKError>) -> Void) {
        guard let request = sdkManager.authInfo else { return }
        network.request(AuthTarget.auth(redirectUri: request.redirectUri,
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
                                        resourceName: Bundle.main.displayName ?? "None"),
                        to: AuthRefreshModel.self) { [weak self] result in
            switch result {
            case .success(let result):
                self?.authManager.userInfo = result.userInfo
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
