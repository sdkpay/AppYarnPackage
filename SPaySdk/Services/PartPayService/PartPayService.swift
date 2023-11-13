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
                                                                analytics: container.resolve(),
                                                                parsingErrorAnaliticManager: container.resolve(),
                                                                featureToggle: container.resolve())
            return service
        })
    }
}

enum BnplConstants {
    static func apiKey(for state: NetworkState) -> String {
        switch state {
        case .Prom:
            return "AHMjXmv8vkVhvybwIqlm2cIAAAAAAAAADHRDSikJqKmlyVz6NxPPBwS3tuDjhZMYQjoj4LwfvhrdJ2w5XUfZc8/nGNWtc0QVMH37jvx5G3B+HqJ8/eMEN6xOXD7cxvXGdN2eh1l7oc6wqq+IozWI+jtlX6R5ZfpqT2c0aEAEZegwFuhfg66gBKi4DdMcDw==" // swiftlint:disable:this line_length
        case .Ift:
            return "AL6zIhba+UMTsQmd/nRpFbQAAAAAAAAADJXNTkFfYPGQfnUNkAile/7RAcbRtqIcsm64coPhlMKLhpc9J5vJq8hTm9JkA2FFyrZPBJ56e1yyaAiQ47r74zhUDkBXwbmVOKOXIQTnhFflBcpIpwsrCMVSNPGAhFR7z3DqbwSf3qzJ0gLOcoEte/nQs8sNbw==" // swiftlint:disable:this line_length
        default:
            return "AHMjXmv8vkVhvybwIqlm2cIAAAAAAAAADHRDSikJqKmlyVz6NxPPBwS3tuDjhZMYQjoj4LwfvhrdJ2w5XUfZc8/nGNWtc0QVMH37jvx5G3B+HqJ8/eMEN6xOXD7cxvXGdN2eh1l7oc6wqq+IozWI+jtlX6R5ZfpqT2c0aEAEZegwFuhfg66gBKi4DdMcDw==" // swiftlint:disable:this line_length
        }
    }
    static func merchantLogin(for state: NetworkState) -> String {
        switch state {
        case .Prom:
            return "bnpl-sbrf"
        case .Ift:
            return "bnpl_sbrf"
        default:
            return "bnpl-sbrf"
        }
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
    private let analytics: AnalyticsService
    private let parsingErrorAnaliticManager: ParsingErrorAnaliticManager
    private(set) var bnplplan: BnplModel?
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager,
         analytics: AnalyticsService,
         parsingErrorAnaliticManager: ParsingErrorAnaliticManager,
         featureToggle: FeatureToggleService) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        self.analytics = analytics
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
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
        analytics.sendEvent(.RQBnpl,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        network.request(BnplTarget.getBnplPlan(sessionId: sessionId,
                                               merchantLogin: merchantLogin,
                                               orderId: orderId),
                        to: BnplModel.self) { [weak self] result in
            switch result {
            case .success(let bnplplan):
                self?.bnplplan = bnplplan
                self?.analytics.sendEvent(.RQGoodBnpl,
                                          with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
                self?.analytics.sendEvent(.RSGoodBnpl,
                                          with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
                self?.setEnabledBnpl(bnplplan.isBnplEnabled, enabledLevel: .bnplPlan)
                completion(nil)
            case .failure(let error):
                self?.parsingErrorAnaliticManager.sendAnaliticsError(error: error, type: .bnpl)
                completion(error)
            }
        }
    }
    
    private func checkFeatureToggle() {
        setEnabledBnpl(featureToggle.isEnabled(.bnpl2), enabledLevel: .featureToggle)
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
