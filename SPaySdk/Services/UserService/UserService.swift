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
                                                          analytics: container.resolve(),
                                                          parsingErrorAnaliticManager: container.resolve())
            return service
        }
    }
}

protocol UserService {
    var getListCards: Bool { get }
    var additionalCards: Bool { get }
    var user: User? { get }
    var selectedCard: PaymentToolInfo? { get set }
    func getUser() async throws
    func getListCards() async throws
    func checkUserSession() async throws
    func clearData()
}

final class DefaultUserService: UserService {
    private let network: NetworkService
    private(set) var user: User?
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private let analytics: AnalyticsService
    private let parsingErrorAnaliticManager: ParsingErrorAnaliticManager
    var getListCards = false
    
    var selectedCard: PaymentToolInfo?
    
    private(set) var additionalCards = false
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager,
         analytics: AnalyticsService,
         parsingErrorAnaliticManager: ParsingErrorAnaliticManager) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        self.analytics = analytics
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func getUser() async throws {
        
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId
        else { throw SDKError(.noData) }
        
        let listCardsResult = try await network.request(UserTarget.getListCards(sessionId: sessionId,
                                                                                merchantLogin: authInfo.merchantLogin,
                                                                                orderId: authInfo.orderId,
                                                                                amount: authInfo.amount,
                                                                                currency: authInfo.currency,
                                                                                orderNumber: authInfo.orderNumber,
                                                                                expiry: authInfo.expiry,
                                                                                frequency: authInfo.frequency,
                                                                                priorityCardOnly: true),
                                                        to: User.self)
        self.user = listCardsResult
        additionalCards = listCardsResult.additionalCards ?? false
        selectedCard = self.selectCard(from: listCardsResult.paymentToolInfo)
    }
    
    func getListCards() async throws {
        
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId
        else { throw SDKError(.noData) }
        
        analytics.sendEvent(.RQListCards, with: [.view: AnlyticsScreenEvent.PaymentVC.rawValue])
        
        do {
            let listCardsResult = try await network.request(UserTarget.getListCards(sessionId: sessionId,
                                                                                    merchantLogin: authInfo.merchantLogin,
                                                                                    orderId: authInfo.orderId,
                                                                                    amount: authInfo.amount,
                                                                                    currency: authInfo.currency,
                                                                                    orderNumber: authInfo.orderNumber,
                                                                                    expiry: authInfo.expiry,
                                                                                    frequency: authInfo.frequency,
                                                                                    priorityCardOnly: false),
                                                            to: User.self)
            
            self.user = listCardsResult
            self.getListCards = true
            
            self.analytics.sendEvent(.RQGoodListCards,
                                     with: [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue])
            self.analytics.sendEvent(.RSGoodListCards,
                                     with: [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue])
        } catch {
            if let error = error as? SDKError {
                parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                               type: .listCards)
            }
            throw error
        }
    }
    
    func checkUserSession() async throws {
        
        guard let sessionId = authManager.sessionId, user != nil else {
            throw SDKError(.noData)
        }
        
        try await network.request(AuthTarget.checkSession(sessionId: sessionId))
    }
    
    func clearData() {
        user = nil
    }
    
    private func selectCard(from cards: [PaymentToolInfo]) -> PaymentToolInfo? {
        
        cards.first(where: { $0.priorityCard }) ?? cards.first
    }
}
