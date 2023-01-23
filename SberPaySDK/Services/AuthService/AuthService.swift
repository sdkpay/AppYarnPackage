//
//  AuthService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

protocol AuthService {
    func tryToAuth(with request: SBPaymentTokenRequest,
                   completion: @escaping (Result<BankModel, SDKError>) -> Void)
    func completeAuth(with url: URL)
    func removeSavedBank()
    var selectedBank: BankApp? { get set }
    func selectBank(_ app: BankApp)
    var avaliableBanks: [BankApp] { get }
}

final class DefaultAuthService: AuthService, ResponseDecoder {
    private var authСompletion: ((Result<BankModel, SDKError>) -> Void)?
    private var analytics: AnalyticsService
    
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
    
    init(analytics: AnalyticsService) {
        self.analytics = analytics
    }

    func selectBank(_ app: BankApp) {
        selectedBank = app
    }

    func tryToAuth(with request: SBPaymentTokenRequest,
                   completion: @escaping (Result<BankModel, SDKError>) -> Void) {
        self.authСompletion = completion
        // DEBUG
        sberIdAuth(clientId: request.apiKey,
                   scope: "openid",
                   state: .generateRandom(with: 12),
                   nonce: .generateRandom(with: 18),
                   redirectUri: request.redirectUri)
    }
    
    func completeAuth(with url: URL) {
        authСompletion?(decodeParametersFrom(url: url))
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
    private func sberIdAuth(clientId: String,
                            scope: String,
                            state: String,
                            nonce: String,
                            redirectUri: String) {
        let params = requestParams(clientId: clientId,
                                   scope: scope,
                                   state: state,
                                   nonce: nonce,
                                   redirectUri: redirectUri)
        guard let url = authURL(items: params) else { return }
        UIApplication.shared.open(url) { [weak self] success in
            self?.analytics.sendEvent(.AuthViewAppeared)
            if !success {
                self?.analytics.sendEvent(.RedirectDenied)
            }
        }
        SBLogger.logRequestToSbolStarted(url)
    }
    
    private func requestParams(clientId: String,
                               scope: String,
                               state: String,
                               nonce: String,
                               redirectUri: String) -> [URLQueryItem] {
        var queryItems: [String: String] = [:]
        queryItems["client_id"] = clientId
        queryItems["state"] = state
        queryItems["nonce"] = nonce
      // DEBUG
      // queryItems["scope"] = scope
        queryItems["redirect_uri"] = redirectUri
        return queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    private func authURL(items: [URLQueryItem]) -> URL? {
        guard let url = selectedBank?.link else { return nil }
        var urlComp = URLComponents(string: url)
        urlComp?.queryItems = items
        return urlComp?.url
    }
    
    // MARK: - Вспомогательные методы

    private func canOpen(link: String) -> Bool {
        guard let url = URL(string: link) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
