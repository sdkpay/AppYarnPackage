//
//  PartPayService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

final class PartPayServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(PartPayService.self)
    
    func register(in container: LocatorService) {
        container.register(reference: {
            let service: PartPayService = DefaultPartPayService(network: container.resolve(),
                                                                sdkManager: container.resolve(),
                                                                authManager: container.resolve(),
                                                                analytics: container.resolve(),
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
    var bnplCheckAccepted: Bool { get set }
    var bnplplanSelectedPublisher: Published<Bool>.Publisher { get }
    var bnplCheckAcceptedPublisher: Published<Bool>.Publisher { get }
    var bnplplanEnabled: Bool { get }
    func setEnabledBnpl(_ value: Bool, enabledLevel: EnabledLevel)
    var bnplplan: BnplModel? { get }
    func getBnplPlan() async throws
    func clearData()
}

final class DefaultPartPayService: PartPayService {

    @Published var bnplplanSelected = false
    
    var bnplplanSelectedPublisher: Published<Bool>.Publisher { $bnplplanSelected }
    
    @Published var bnplCheckAccepted = true
    
    var bnplCheckAcceptedPublisher: Published<Bool>.Publisher { $bnplCheckAccepted }
    
    var bnplplanEnabled: Bool {
        bnplAvaliable
    }
    
    private var bnplEnabledLevels: [EnabledLevel: Bool] = [:]
    
    private let network: NetworkService
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private let featureToggle: FeatureToggleService
    private var userEnableBnpl = false
    private let analytics: AnalyticsService
    private(set) var bnplplan: BnplModel?
    
    init(network: NetworkService,
         sdkManager: SDKManager,
         authManager: AuthManager,
         analytics: AnalyticsService,
         featureToggle: FeatureToggleService) {
        self.network = network
        self.sdkManager = sdkManager
        self.authManager = authManager
        self.analytics = analytics
        self.featureToggle = featureToggle
        setEnabledBnpl(authManager.bnplMerchEnabled, enabledLevel: .merch)
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func setEnabledBnpl(_ value: Bool, enabledLevel: EnabledLevel) {
        bnplEnabledLevels[enabledLevel] = value
    }
    
    func getBnplPlan() async throws {
        switch sdkManager.payStrategy {
        case .auto, .manual:
            try await getFourPartsPlan()
        case .withoutRefresh, .partPay:
            try await getSixPartsPlan()
        }
    }
    
    private func getFourPartsPlan() async throws {
        
        guard featureToggle.isEnabled(.bnpl)
                && authManager.bnplMerchEnabled
                && authManager.authModel?.isBnplEnabled ?? false else { return }
        
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId,
              let merchantLogin = authInfo.merchantLogin,
              let orderId = authInfo.orderId
        else { throw SDKError(.noData) }
  
        do {
            let bnplResult = try await network.request(BnplTarget.getBnplPlan(sessionId: sessionId,
                                                                              merchantLogin: merchantLogin,
                                                                              orderId: orderId),
                                                       to: BnplModel.self)
            
            self.bnplplan = bnplResult
            self.setEnabledBnpl(bnplResult.isBnplEnabled, enabledLevel: .bnplPlan)
        } catch {
            self.setEnabledBnpl(false, enabledLevel: .bnplPlan)
            throw error
        }
    }
    
    private func getSixPartsPlan() async throws {
        
        guard featureToggle.isEnabled(.bnpl)
                && authManager.bnplMerchEnabled
                && authManager.authModel?.isBnplEnabled ?? false else { return }
        
        guard let authInfo = sdkManager.authInfo,
              let sessionId = authManager.sessionId,
              let merchantLogin = authInfo.merchantLogin,
              let orderId = authInfo.orderId
        else { throw SDKError(.noData) }
        do {
            let bnplResult = try await network.request(BnplTarget.createPaymentPlan(sessionId: sessionId,
                                                                                    merchantLogin: merchantLogin,
                                                                                    orderId: orderId),
                                                       to: BnplModel.self)
            
            self.bnplplan = bnplResult
            self.setEnabledBnpl(bnplResult.isBnplEnabled, enabledLevel: .bnplPlan)
        } catch {
            self.setEnabledBnpl(false, enabledLevel: .bnplPlan)
            throw error
        }
    }
    
    func clearData() {
        bnplplanSelected = false
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
