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
                                                          authManager: container.resolve(),
                                                          analytics: container.resolve())
            return service
        }
    }
}

protocol UserService {
    var getListCards: Bool { get }
    var additionalCards: Bool { get }
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
    private let analytics: AnalyticsService
    var getListCards = false
    
    var selectedCard: PaymentToolInfo?
    
    private(set) var additionalCards = false
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager,
         analytics: AnalyticsService) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        self.analytics = analytics
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func getUser(completion: @escaping (SDKError?) -> Void) {
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId
        else { return }
        network.request(UserTarget.getListCards(sessionId: sessionId,
                                                merchantLogin: authInfo.merchantLogin,
                                                orderId: authInfo.orderId,
                                                amount: authInfo.amount,
                                                currency: authInfo.currency,
                                                orderNumber: authInfo.orderNumber,
                                                expiry: authInfo.expiry,
                                                frequency: authInfo.frequency,
                                                priorityCardOnly: true),
                        to: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                guard let self = self else { return }
                self.user = user
                self.additionalCards = user.additionalCards ?? false
                self.selectedCard = self.selectCard(from: user.paymentToolInfo)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func getListCards(completion: @escaping (Result<Void, SDKError>) -> Void) {
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId
        else { return }
        analytics.sendEvent(.RQListCards, with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
        network.request(UserTarget.getListCards(sessionId: sessionId,
                                                merchantLogin: authInfo.merchantLogin,
                                                orderId: authInfo.orderId,
                                                amount: authInfo.amount,
                                                currency: authInfo.currency,
                                                orderNumber: authInfo.orderNumber,
                                                expiry: authInfo.expiry,
                                                frequency: authInfo.frequency,
                                                priorityCardOnly: false),
                        to: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                guard let self = self else { return }
                self.user = user
                self.getListCards = true
                self.analytics.sendEvent(.RQGoodListCards,
                                         with: [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue])
                self.analytics.sendEvent(.RSGoodListCards,
                                         with: [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue])
                completion(.success)
                completion(.success)
            case .failure(let error):
                self?.sendAnaliticsError(error: error)
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
    
    private func sendAnaliticsError(error: SDKError) {
        switch error {
            
        case .noInternetConnection:
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .noData:
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .badResponseWithStatus(let code):
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: code.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .failDecode(let text):
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: Int64(200),
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
            self.analytics.sendEvent(
                .RSFailListCards,
                with:
                    [
                        AnalyticsKey.ParsingError: text
                    ])
        case .badDataFromSBOL(let httpCode):
            self.analytics.sendEvent(
                .RQFailListCards,
                with: 
                    [
                        AnalyticsKey.httpCode: httpCode
                    ]
            )
        case .unauthorizedClient(let httpCode):
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .personalInfo:
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .errorWithErrorCode(let number, let httpCode):
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.errorCode: number,
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .noCards:
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .cancelled:
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .timeOut(let httpCode):
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        case .ssl(let httpCode):
            self.analytics.sendEvent(
                .RQFailListCards,
                with:
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue
                    ]
            )
        }
    }
}
