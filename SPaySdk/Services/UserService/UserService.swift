//
//  UserService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

final class UserServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(UserService.self)
    
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
    var getListCards: Bool { get set }
    var additionalCards: Bool { get }
    var user: UserModel? { get }
    var selectedCard: PaymentTool? { get set }
    var selectedCardPublisher: Published<PaymentTool?>.Publisher { get }
    func getUser() async throws
    func getListCards() async throws
    func checkUserSession() async throws
    func clearData()
}

final class DefaultUserService: UserService {
    
    private let network: NetworkService
    private(set) var user: UserModel?
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private let analytics: AnalyticsService
    
    var getListCards = false
    
    @Published var selectedCard: PaymentTool?
    
    var selectedCardPublisher: Published<PaymentTool?>.Publisher { $selectedCard }
    
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
                                                                                priorityCardOnly: false),
                                                        to: UserModel.self)
        self.user = listCardsResult
        additionalCards = listCardsResult.paymentToolInfo.paymentTool.count > 1
        selectedCard = self.selectCard(from: listCardsResult.paymentToolInfo.paymentTool)
    }
    
    func getListCards() async throws {
        
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId
        else { throw SDKError(.noData) }
        
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
                                                            to: UserModel.self)
            
            self.user = listCardsResult
        } catch {
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
    
    private func selectCard(from cards: [PaymentTool]) -> PaymentTool? {
        
        cards.first(where: { $0.priorityCard })
    }
}
