//
//  UserService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

protocol UserService {
    var user: User? { get }
    func getUser(completion: @escaping (Result<User, SDKError>) -> Void)
}

final class DefaultUserService: UserService {
    private let network: NetworkService
    private(set) var user: User?
    private let sdkManager: SDKManager
    private let authManager: AuthManager

    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
    }

    func getUser(completion: @escaping (Result<User, SDKError>) -> Void) {
        guard let request = sdkManager.paymentTokenRequest,
              let sessionId = authManager.sessionId,
              let authCode = authManager.authCode,
              let state = authManager.state
        else { return }
        network.request(UserTarget.getListCards(redirectUri: request.redirectUri,
                                                apiKey: request.apiKey,
                                                authCode: authCode,
                                                sessionId: sessionId,
                                                state: state,
                                                merchantLogin: request.clientName,
                                                orderId: request.orderNumber),
                        to: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
