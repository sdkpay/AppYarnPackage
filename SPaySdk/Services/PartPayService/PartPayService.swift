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
                                                                analitics: container.resolve(),
                                                                featureToggle: container.resolve())
            return service
        })
    }
}

enum EnabledLevel: String {
    case featureToggle
    case merch
    case session
    case bnplPlan
    case paymentToken
}

protocol PartPayService {
    var bnplplanSelected: Bool { get set }
    var bnplplanEnabled: Bool { get }
    func setEnabledBnpl(_ value: Bool, enabledLevel: EnabledLevel)
    var bnplplan: BnplModel? { get }
    func getBnplPlan(completion: @escaping (SDKError?) -> Void)
}

final class DefaultPartPayService: PartPayService {
    
    var bnplplanSelected = false
    
    var bnplplanEnabled: Bool {
        switch bnplAvaliable {
        case true:
            return bnplplan?.integrityCheck == true
        case false:
            return false
        }
    }
    
    private var bnplEnabledLevels: [EnabledLevel: Bool] = [:]
    
    private let network: NetworkService
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private let featureToggle: FeatureToggleService
    private var userEnableBnpl = false
    private let analitics: AnalyticsService
    private(set) var bnplplan: BnplModel?
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager,
         analitics: AnalyticsService,
         featureToggle: FeatureToggleService) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        self.analitics = analitics
        self.featureToggle = featureToggle
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func setEnabledBnpl(_ value: Bool, enabledLevel: EnabledLevel) {
        bnplEnabledLevels[enabledLevel] = value
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
                self?.setEnabledBnpl(bnplplan.isBnplEnabled, enabledLevel: .bnplPlan)
                completion(nil)
            case .failure(let error):
                if error.represents(.failDecode) {
                    self?.analitics.sendEvent(.RQFailBnpl, with: [AnalyticsKey.ParsingError: error.localizedDescription])
                } else {
                    self?.analitics.sendEvent(.RSFailBnpl, with: [AnalyticsKey.errorCode: error.localizedDescription])
                }
                completion(error)
            }
        }
    }
    
    private func checkFeatureToggle() {
        setEnabledBnpl(featureToggle.isEnabled(.bnpl), enabledLevel: .featureToggle)
    }
    
    private var bnplAvaliable: Bool {
        checkFeatureToggle()
        let bnplEnabledLevelsLog = bnplEnabledLevels.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }.json
        SBLogger
            .log(
                level: .debug(level: .defaultLevel),
                """
                💶 BNPL levels:
                   path: \(bnplEnabledLevelsLog)
                """)
        return !bnplEnabledLevels.values.contains(false)
    }
}
