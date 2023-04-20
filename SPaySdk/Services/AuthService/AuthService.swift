//
//  AuthService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class AuthServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: AuthService = DefaultAuthService(network: container.resolve(),
                                                      sdkManager: container.resolve(),
                                                      analytics: container.resolve(),
                                                      bankAppManager: container.resolve(),
                                                      authManager: container.resolve(),
                                                      personalMetricsService: container.resolve())
        container.register(service: service)
    }
}

protocol AuthService {
    func tryToAuth(completion: @escaping (SDKError?) -> Void)
    func completeAuth(with url: URL)
}

final class DefaultAuthService: AuthService, ResponseDecoder {
    private var authСompletion: ((SDKError?) -> Void)?
    private var analytics: AnalyticsService
    private let network: NetworkService
    private let sdkManager: SDKManager
    private let bankAppManager: BankAppManager
    private var authManager: AuthManager
    private var personalMetricsService: PersonalMetricsService
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         analytics: AnalyticsService,
         bankAppManager: BankAppManager,
         authManager: AuthManager,
         personalMetricsService: PersonalMetricsService) {
        self.analytics = analytics
        self.network = network
        self.sdkManager = sdkManager
        self.bankAppManager = bankAppManager
        self.authManager = authManager
        self.personalMetricsService = personalMetricsService
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func tryToAuth(completion: @escaping (SDKError?) -> Void) {
        // Проверка на целостность
        personalMetricsService.integrityCheck { [weak self] result in
            if result {
                // Запрос на получение сессии
                self?.authRequest(completion: completion)
            } else {
                // Ошибка авторизации
                completion(.personalInfo)
            }
        }
    }
    
    private func authRequest(completion: @escaping (SDKError?) -> Void) {
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
                self?.authManager.sessionId = result.sessionId
                self?.sIdAuth(with: result)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func completeAuth(with url: URL) {
        switch decodeParametersFrom(url: url) {
        case .success(let result):
            authManager.authCode = result.code
            authManager.state = result.state
            authСompletion?(nil)
        case .failure(let error):
            authСompletion?(error)
        }
        // Сохраняем выбранный банк если произошел успешный редирект обратно в приложение
        bankAppManager.saveSelectedBank()
    }
    
    // MARK: - Методы авторизации через sId
    private func sIdAuth(with model: AuthModel) {
        guard let link = authURL(link: model.deeplink) else {
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
}
