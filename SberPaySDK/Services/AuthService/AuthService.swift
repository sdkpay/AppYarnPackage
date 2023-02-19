//
//  AuthService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class AuthServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: AuthService = DefaultAuthService(network: container.resolve(),
                                                      sdkManager: container.resolve(),
                                                      analytics: container.resolve(),
                                                      authManager: container.resolve())
        container.register(service: service)
    }
}

protocol AuthService {
    func tryToAuth(completion: @escaping (SDKError?) -> Void)
    func completeAuth(with url: URL)
    func removeSavedBank()
    var selectedBank: BankApp? { get set }
    func selectBank(_ app: BankApp)
    var avaliableBanks: [BankApp] { get }
}

final class DefaultAuthService: AuthService, ResponseDecoder {
    private var authСompletion: ((SDKError?) -> Void)?
    private var analytics: AnalyticsService
    private let network: NetworkService
    private let sdkManager: SDKManager
    private var authManager: AuthManager

    var avaliableBanks: [BankApp] {
        BankApp.allCases.filter({ canOpen(link: $0.link) })
    }
    
    private var _selectedBank: BankApp?
    
    var selectedBank: BankApp? {
        get {
            if let bankApp = getSelectedBank(),
               canOpen(link: bankApp.link) {
                return bankApp
            } else {
                return nil
            }
        } set {
            _selectedBank = newValue
        }
    }
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         analytics: AnalyticsService,
         authManager: AuthManager) {
        self.analytics = analytics
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
    }

    func selectBank(_ app: BankApp) {
        selectedBank = app
    }
    
    func tryToAuth(completion: @escaping (SDKError?) -> Void) {
        guard let request = sdkManager.authInfo else { return }
        network.request(AuthTarget.getSessionId(redirectUri: request.redirectUri,
                                                merchantLogin: request.clientName,
                                                orderId: request.orderId),
                        to: AuthModel.self) { [weak self] result in
            self?.authСompletion = completion
            switch result {
            case .success(let result):
                self?.authManager.sessionId = result.sessionId
                self?.sberIdAuth(with: result)
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
            if BuildSettings.needStubs {
                // DEBUG
                authManager.authCode = ""
                authManager.state = ""
            }
            authСompletion?(error)
        }
        // Сохраняем выбранный банк если произошел успешный редирект обратно в приложение
        saveSelectedBank()
    }
    
    func removeSavedBank() {
        SBLogger.log("🗑 Remove value for key: selectedBank")
        UserDefaults.standard.removeObject(forKey: "selectedBank")
    }
    
    private func saveSelectedBank() {
        UserDefaults.bankApp = _selectedBank?.rawValue
    }
    
    private func getSelectedBank() -> BankApp? {
        // Проверяем есть ли выбранное приложение
        if let selectedBank = _selectedBank {
            return selectedBank
        }
        if avaliableBanks.count > 1 {
            // Если больше 1 то смотрим на сохраненный банк
            if let savedBank = UserDefaults.bankApp {
                _selectedBank = BankApp(rawValue: savedBank)
                return _selectedBank
            } else {
                return nil
            }
        } else {
            // Берем единственный банк на устройстве
            _selectedBank = avaliableBanks.first
            return _selectedBank
        }
    }

    // MARK: - Методы авторизации через sberid
    private func sberIdAuth(with model: AuthModel) {
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
        guard let url = selectedBank?.link else { return nil }
        let tLink = "sberbankid?client_id=9f80261c-3455-4942-be48-cd1b2a2d7ba5&state=R2V4T2lOA16&scope=openid+name+birthdate+priority_doc+mobile&code_challenge_method=S256&code_challenge=lsme-Q-_tdwJmBr-02e0_GRqYCakqBEpH1VMKyc6_7Y&redirect_uri=sberPayExampleapp://sberidauth" // swiftlint:disable:this line_length
        return URL(string: url + tLink)
    }
    
    // MARK: - Вспомогательные методы

    private func canOpen(link: String) -> Bool {
        guard let url = URL(string: link) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
