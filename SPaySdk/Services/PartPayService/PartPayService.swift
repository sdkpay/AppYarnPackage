//
//  PartPayService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

final class PartPayServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: PartPayService = DefaultPartPayService(network: container.resolve(),
                                                            sdkManager: container.resolve(),
                                                            authManager: container.resolve())
        container.register(service: service)
    }
}

protocol PartPayService {
    var bnplplanSelected: Bool { get set }
    var bnplplan: BnplModel? { get }
    func getBnplPlan(completion: @escaping (SDKError?) -> Void)
}

final class DefaultPartPayService: PartPayService {
    private let network: NetworkService
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    
    var bnplplanSelected = false
    
    private(set) var bnplplan: BnplModel?
    
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
    
    func getBnplPlan(completion: @escaping (SDKError?) -> Void) {
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId
        else { return }
        network.request(BnplTarget.getBnplPlan(sessionId: sessionId,
                                               merchantLogin: authInfo.merchantLogin,
                                               orderId: authInfo.orderId),
                        to: BnplModel.self) { [weak self] result in
            switch result {
            case .success(let bnplplan):
                self?.bnplplan = bnplplan
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
