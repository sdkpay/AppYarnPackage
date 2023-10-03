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
                                                                featureToggle: container.resolve())
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
        if featureToggle.isEnabled(.bnpl),
            bnplplan?.isBnplEnabled ?? false {
            return userEnableBnpl
        } else {
            return false
        }
    }
    
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
        analytics.sendEvent(.RQBnpl,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        network.request(BnplTarget.getBnplPlan(sessionId: sessionId,
                                               merchantLogin: merchantLogin,
                                               orderId: orderId),
                        to: BnplModel.self) { [weak self] result in
            switch result {
            case .success(let bnplplan):
                self?.bnplplan = bnplplan
                self?.analytics.sendEvent(.RQGoodBnpl)
                completion(nil)
            case .failure(let error):
                self?.sendAnaliticsError(error: error)
                completion(error)
            }
        }
    }
    
    private func sendAnaliticsError(error: SDKError) {
        switch error {
            
        case .noInternetConnection:
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .noData:
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .badResponseWithStatus(let code):
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: code.rawValue,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .failDecode(let text):
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: 200,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
            self.analytics.sendEvent(
                .RSFailBnpl,
                with: [AnalyticsKey.ParsingError: text])
        case .badDataFromSBOL(let httpCode):
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: httpCode]
            )
        case .unauthorizedClient(let httpCode):
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: httpCode,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .personalInfo:
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .errorWithErrorCode(let number, let httpCode):
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.errorCode: number,
                       AnalyticsKey.httpCode: httpCode,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .noCards:
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .cancelled:
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .timeOut(let httpCode):
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: httpCode,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        case .ssl(let httpCode):
            self.analytics.sendEvent(
                .RQFailBnpl,
                with: [AnalyticsKey.httpCode: httpCode,
                       AnalyticsKey.errorCode: -1,
                       AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
            )
        }
    }
}
