//
//  UserService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

final class UserServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: UserService = DefaultUserService(network: container.resolve(),
                                                          sdkManager: container.resolve(),
                                                          authManager: container.resolve())
            return service
        }
    }
}

protocol UserService {
    var gotListCards: Bool { get }
    var user: User? { get }
    var selectedCard: PaymentToolInfo? { get set }
    func getUser(completion: @escaping (SDKError?) -> Void)
    func getListCards(completion: @escaping (Result<Void, SDKError>) -> Void)
    func checkUserSession(completion: @escaping (Result<Void, SDKError>) -> Void)
    func clearData()
}

final class DefaultUserService: UserService {
    private let network: NetworkService
    private(set) var user: User?
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    var gotListCards = false
    
    var selectedCard: PaymentToolInfo?
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func getUser(completion: @escaping (SDKError?) -> Void) {
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId,
              let authCode = authManager.authCode,
              let state = authManager.state
        else { return }
        
        network.request(UserTarget.getListCards(redirectUri: authInfo.redirectUri,
                                                authCode: authCode,
                                                sessionId: sessionId,
                                                state: state,
                                                merchantLogin: authInfo.merchantLogin,
                                                orderId: authInfo.orderId,
                                                amount: authInfo.amount,
                                                currency: authInfo.currency,
                                                orderNumber: authInfo.orderNumber,
                                                expiry: authInfo.expiry,
                                                frequency: authInfo.frequency,
                                                listPaymentCards: false),
                        to: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                guard let self = self else { return }
                self.user = user
                self.selectedCard = self.selectCard(from: user.paymentToolInfo)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func getListCards(completion: @escaping (Result<Void, SDKError>) -> Void) {
        guard authManager.authMethod == .bank else { return }
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId,
              let authCode = authManager.authCode,
              let state = authManager.state
        else { return }
        
        network.request(UserTarget.getListCards(redirectUri: authInfo.redirectUri,
                                                authCode: authCode,
                                                sessionId: sessionId,
                                                state: state,
                                                merchantLogin: authInfo.merchantLogin,
                                                orderId: authInfo.orderId,
                                                amount: authInfo.amount,
                                                currency: authInfo.currency,
                                                orderNumber: authInfo.orderNumber,
                                                expiry: authInfo.expiry,
                                                frequency: authInfo.frequency,
                                                listPaymentCards: true),
                        to: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                guard let self = self else { return }
                self.user = user
                self.gotListCards = true
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func checkUserSession(completion: @escaping (Result<Void, SDKError>) -> Void) {
        guard let sessionId = authManager.sessionId, user != nil else {
            completion(.failure(.noData))
            return
        }
        network.request(AuthTarget.checkSession(sessionId: sessionId),
                        completion: completion)
    }
    
    func clearData() {
        user = nil
    }

    private func selectCard(from cards: [PaymentToolInfo]) -> PaymentToolInfo? {
        cards.first(where: { $0.priorityCard }) ?? cards.first
    }
}
