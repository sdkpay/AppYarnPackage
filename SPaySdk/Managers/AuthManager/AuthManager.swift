//
//  AuthManager.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

enum AuthMethod {
    case refresh
    case bank
    case sid
}

final class AuthManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(AuthManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: AuthManager = DefaultAuthManager()
            return service
        }
    }
}

protocol AuthManager {
    
    var orderNumber: String? { get set }
    var apiKey: String? { get set }
    var sessionId: String? { get set }
    var authCode: String? { get set }
    var state: String? { get set }
    var lang: String? { get set }
    var isOtpNeed: Bool? { get set }
    var userInfo: UserInfoModel? { get set }
    var authMethod: AuthMethod? { get set }
    var ipAddress: String? { get set }
    var authModel: AuthModel? { get set }
    var bnplMerchEnabled: Bool { get }
    var spasiboBonusesEnabled: Bool { get }
    var initialApiKey: String? { get set }
    func getParamsForBankAuth() throws -> (authCode: String, state: String)
    func setEnabledBnpl(_ value: Bool)
    func setEnableBonuses(_ value: Bool)
}

final class DefaultAuthManager: AuthManager {

    var orderNumber: String?
    var apiKey: String?
    var sessionId: String?
    var authCode: String?
    var state: String?
    var lang: String?
    var ipAddress: String?
    var userInfo: UserInfoModel?
    var authMethod: AuthMethod? {
        didSet {
            SBLogger.log("🚪 Метод авторизации изменился на \(String(describing: authMethod ?? .none))")
        }
    }
    var isOtpNeed: Bool?
    var authModel: AuthModel?
    var bnplMerchEnabled = false
    var spasiboBonusesEnabled = false
    
    var initialApiKey: String?
    
    func setEnabledBnpl(_ value: Bool) {
        bnplMerchEnabled = value
    }
    
    func getParamsForBankAuth() throws -> (authCode: String, state: String) {
        
        guard let authCode else { throw SDKError(.noData) }
        guard let state else { throw SDKError(.noData) }
        
        return (authCode, state)
        
    func setEnableBonuses(_ value: Bool) {
        spasiboBonusesEnabled = value
    }
}
