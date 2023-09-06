//
//  PartPayService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

final class PartPayServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register(reference: {
            let service: PartPayService = DefaultPartPayService(network: container.resolve(),
                                                                sdkManager: container.resolve(),
                                                                authManager: container.resolve(),
                                                                featureToggle: container.resolve(),
                                                                analitics: container.resolve())
            return service
        })
    }
}

enum EnabledLevel {
    case merch
    case server
}

protocol PartPayService {
    var bnplplanSelected: Bool { get set }
    var bnplplanEnabled: Bool { get }
    func setUserEnableBnpl(_ value: Bool, enabledLevel: EnabledLevel)
    var bnplplan: BnplModel? { get }
    func getBnplPlan(completion: @escaping (SDKError?) -> Void)
}

final class DefaultPartPayService: PartPayService {
    var bnplplanSelected = false
    
    var bnplplanEnabled: Bool {
        if featureToggle.isEnabled(.bnpl) {
            return userEnableBnpl
        } else {
            return false
        }
    }
    
    private let network: NetworkService
    private let sdkManager: SDKManager
    private let analitics: AnalyticsService
    private let authManager: AuthManager
    private let featureToggle: FeatureToggleService
    private var userEnableBnpl = false
    private(set) var bnplplan: BnplModel?
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager,
         featureToggle: FeatureToggleService,
         analitics: AnalyticsService) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        self.featureToggle = featureToggle
        self.analitics = analitics
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func setUserEnableBnpl(_ value: Bool, enabledLevel: EnabledLevel) {
        switch enabledLevel {
        case .merch:
            userEnableBnpl = value
        case .server:
            if userEnableBnpl {
                userEnableBnpl = value
            }
        }
    }
    
    func getBnplPlan(completion: @escaping (SDKError?) -> Void) {
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId,
              let merchantLogin = authInfo.merchantLogin,
              let orderId = authInfo.orderId
        else { return completion(nil) }
        analitics.sendEvent(.RQBnpl)
        network.request(BnplTarget.getBnplPlan(sessionId: sessionId,
                                               merchantLogin: merchantLogin,
                                               orderId: orderId),
                        to: BnplModel.self) { [weak self] result in
            switch result {
            case .success(let bnplplan):
                self?.bnplplan = bnplplan
                self?.analitics.sendEvent(.RQGoodBnpl)
                completion(nil)
            case .failure(let error):
                self?.analitics.sendEvent(.RQFailBnpl)
                completion(error)
            }
        }
    }
}
