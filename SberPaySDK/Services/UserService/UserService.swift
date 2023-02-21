//
//  UserService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

final class UserServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: UserService = DefaultUserService(network: container.resolve(),
                                                      sdkManager: container.resolve(),
                                                      authManager: container.resolve())
        container.register(service: service)
    }
}

protocol UserService {
    var user: User? { get }
    func getUser(completion: @escaping (Result<User, SDKError>) -> Void)
    func checkUserSession(completion: @escaping (Result<ValidSessionModel, SDKError>) -> Void)
    func clearData()
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
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId,
              let authCode = authManager.authCode,
              let state = authManager.state
        else { return }
        network.request(UserTarget.getListCards(redirectUri: authInfo.redirectUri,
                                                authCode: authCode,
                                                sessionId: sessionId,
                                                state: state,
                                                merchantLogin: authInfo.clientName,
                                                orderId: authInfo.orderId),
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
    
    func checkUserSession(completion: @escaping (Result<ValidSessionModel, SDKError>) -> Void) {
        guard let sessionId = authManager.sessionId else { return }
        network.request(UserTarget.checkSession(sessionId: String(sessionId)),
                        to: ValidSessionModel.self,
                        completion: completion)
    }
    
    func clearData() {
        user = nil
    }
}
