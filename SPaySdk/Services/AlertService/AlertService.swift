//
//  AlertService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 27.02.2023.
//

import UIKit

struct AlertButtonModel {
    let title: String
    let type: DefaultButtonAppearance
    let neededResult: AlertResult
    let action: Action?
}

struct AlertViewModel {
    let image: UIImage?
    let lottie: String
    let title: String
    let subtite: String?
    let cost: String?
    let buttons: [AlertButtonModel]
    let sound: String
    let feedBack: UINotificationFeedbackGenerator.FeedbackType
    let isFailure: Bool
    let bonuses: String?
}

enum AlertState {
    case success
    case failure
    case waiting
    case warning
    
    var soundPath: String {
        switch self {
        case .success:
            return "poz.mp3"
        case .failure:
            return "neg.mp3"
        case .waiting:
            return "progress.mp3"
        case .warning:
            return "neg.mp3"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .success:
            return .Common.success
        case .failure:
            return .Common.failure
        case .waiting:
            return .Common.waiting
        case .warning:
            return .Common.warningAlert
        }
    }
    
    var lottieName: String {
        switch self {
        case .success:
            return Files.Lottie.successJson.name
        case .failure:
            return Files.Lottie.errorJson.name
        case .waiting:
            return Files.Lottie.successJson.name
        case .warning:
            return Files.Lottie.errorJson.name
        }
    }
    
    var feedBack: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success:
            return .success
        case .failure:
            return .warning
        case .waiting:
            return .success
        case .warning:
            return .warning
        }
    }
}

enum AlertType {
    case paySuccess(amount: String, shopName: String, bonuses: String?)
    case connectSuccess(card: String)
    case defaultError
    case noInternet
    case partPayError
    case tryingError
    case noMoney
    case serverError(subtitle: String)
}

final class AlertServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(AlertService.self)
    
    func register(in container: LocatorService) {
        container.register(reference: {
            let service: AlertService = DefaultAlertService(completionManager: container.resolve(),
                                                            liveCircleManager: container.resolve(),
                                                            analytics: container.resolve(),
                                                            sdkManager: container.resolve(),
                                                            setupManager: container.resolve())
            return service
        })
    }
}

protocol AlertService {
    
    @MainActor
    @discardableResult
    func show(on view: ContentVC?, type: AlertType) async -> AlertResult
    
    @MainActor
    @discardableResult
    func show(on view: ContentVC?,
              with text: String,
              with subtitle: String?,
              with cost: String?,
              with bonuses: String?,
              state: AlertState,
              buttons: [AlertButtonModel]) async -> AlertResult
    
    func showLoading(with text: String?,
                     animate: Bool)
    func hideLoading(animate: Bool)
    func hide(animated: Bool, completion: Action?)
}

extension AlertService {
    
    func showLoading(with text: String? = nil,
                     animate: Bool = true) {
        showLoading(with: text, animate: animate)
    }
    func hideLoading(animate: Bool = true) {
        hideLoading(animate: animate)
    }
    func hide(animated: Bool = true, completion: Action? = nil) {
        hide(animated: animated, completion: completion)
    }
}

enum AlertResult {
    
    case approve
    case cancel
}

final class DefaultAlertService: AlertService {
    
    private let completionManager: CompletionManager
    
    private var alertVC: ContentVC?
    private let analytics: AnalyticsManager
    private let liveCircleManager: LiveCircleManager
    private let sdkManager: SDKManager
    private let setupManager: SetupManager
    
    @MainActor
    @discardableResult
    func show(on view: ContentVC?, type: AlertType) async -> AlertResult {
        
        let event = EventBuilder()
            .with(base: .LC)
            .with(postAction: .Appeared)
        
        var eventValue = [AnalyticsKey: String]()
        
        switch type {
        case let .paySuccess(amount: amount, shopName: shopName, bonuses: bonuses):
            
            event.with(value: MetricsValue(rawValue: "StatusSuccessView"))
            eventValue[.State] = "Success"
            
            guard alertViewNeeded else { return AlertResult.approve }
            
            return await show(on: view,
                              with: amount,
                              with: shopName,
                              with: nil,
                              with: bonuses,
                              state: .success,
                              buttons: [
                                AlertButtonModel(title: Strings.Alert.Button.Close.title,
                                                 type: .full,
                                                 neededResult: .cancel,
                                                 action: {})
                              ])
            
        case .connectSuccess(card: let card):
            
            event.with(value: MetricsValue(rawValue: "StatusSuccessView"))
            eventValue[.State] = "Success"
            
            guard alertViewNeeded else { return AlertResult.approve }
            
            return await show(on: view,
                              with: Strings.Alert.Connect.title(card),
                              with: nil,
                              state: .success,
                              buttons: [
                                AlertButtonModel(title: Strings.Alert.Button.Close.title,
                                                 type: .full,
                                                 neededResult: .cancel,
                                                 action: {})
                                ])
        case .defaultError:
            
            event.with(value: MetricsValue(rawValue: "StatusErrorView"))
            eventValue[.State] = "default"
            
            if sdkManager.payStrategy == .partPay {
                
                return await show(on: view,
                                  with: Strings.Error.Partpay.title,
                                  with: Strings.Error.Partpay.subtitle,
                                  state: .warning,
                                  buttons: [
                                    AlertButtonModel(title: Strings.Alert.Button.Return.title,
                                                     type: .info,
                                                     neededResult: .cancel,
                                                     action: {})
                                  ])
            }
            
            guard alertViewNeeded else { return AlertResult.approve }
            
            return await show(on: view,
                              with: Strings.Alert.Error.Main.title,
                              with: Strings.Alert.Error.Main.subtitle,
                              state: .warning,
                              buttons: [
                                AlertButtonModel(title: Strings.Alert.Button.Return.title,
                                                 type: .info,
                                                 neededResult: .cancel,
                                                 action: {})
                              ])
        case .noInternet:
            
            event.with(value: MetricsValue(rawValue: "StatusErrorView"))
            eventValue[.State] = "NoInternet"
            
            let tryButton = AlertButtonModel(title: Strings.Common.Try.title,
                                             type: .blackBack,
                                             neededResult: .approve,
                                             action: nil)
            let cancelButton = AlertButtonModel(title: Strings.Alert.Button.Return.title,
                                                type: .info,
                                                neededResult: .cancel,
                                                action: nil)
            return await show(on: view,
                              with: Strings.Alert.Pay.No.Internet.title,
                              with: Strings.Alert.Pay.No.Internet.subtitle,
                              state: .warning,
                              buttons:
                                [
                                    tryButton,
                                    cancelButton
                                ])
        case .partPayError:
            
            event.with(value: MetricsValue(rawValue: "StatusErrorView"))
            eventValue[.State] = "PartPayError"
            
            let fullPayButton = AlertButtonModel(title: Strings.Common.Pay.Full.title,
                                                 type: .blackBack,
                                                 neededResult: .approve,
                                                 action: nil)
            let returnButton = AlertButtonModel(title: Strings.Common.Return.title,
                                                type: .info,
                                                neededResult: .cancel,
                                                action: nil)
            return await show(on: view,
                              with: Strings.Alert.Error.Main.title,
                              with: Strings.Alert.Pay.Error.title,
                              state: .failure,
                              buttons: [
                                fullPayButton,
                                returnButton
                              ])
        case .tryingError:
            
            event.with(value: MetricsValue(rawValue: "StatusErrorView"))
            eventValue[.State] = "TryingError"
            
            let fullPayButton = AlertButtonModel(title: Strings.Otp.Button.Otp.back,
                                                 type: .blackBack,
                                                 neededResult: .cancel,
                                                 action: {})
            
            return await show(on: view,
                              with: Strings.Error.trying,
                              with: nil,
                              state: .failure,
                              buttons: [
                                fullPayButton
                              ])
        case .noMoney:
            
            event.with(value: MetricsValue(rawValue: "StatusErrorView"))
            eventValue[.State] = "NoMoney"
            
            let cancel = AlertButtonModel(title: Strings.Common.Return.title,
                                          type: .cancel,
                                          neededResult: .cancel,
                                          action: {})
            return await show(on: view,
                              with: Strings.Error.NoMoney.title,
                              with: Strings.Error.NoMoney.subtitle,
                              state: .failure,
                              buttons: [
                                cancel
                              ])
        case let .serverError(subtitle: subtitle):
            event.with(value: MetricsValue(rawValue: "StatusErrorView"))
            eventValue[.State] = "TimeOutRetry"
            
            let cancel = AlertButtonModel(title: Strings.Common.Return.title,
                                          type: .cancel,
                                          neededResult: .cancel,
                                          action: nil)
            return await show(on: view,
                              with: Strings.Alert.Error.Main.title,
                              with: subtitle,
                              state: .failure,
                              buttons: [
                                cancel
                              ])
        }
        
        analytics.send(event.build(), on: .StatusView, values: eventValue)
    }
    
    @MainActor
    @discardableResult
    func show(on view: ContentVC?,
              with text: String,
              with subtitle: String?,
              with cost: String? = nil,
              with bonuses: String? = nil,
              state: AlertState,
              buttons: [AlertButtonModel]) async -> AlertResult {
        
        let model = AlertViewModel(image: state.image, 
                                   lottie: state.lottieName,
                                   title: text,
                                   subtite: subtitle,
                                   cost: cost,
                                   buttons: buttons,
                                   sound: state.soundPath,
                                   feedBack: state.feedBack,
                                   isFailure: state != .success,
                                   bonuses: bonuses)
        
        let result = await withCheckedContinuation({( inCont: CheckedContinuation<AlertResult, Never>) -> Void in
            
            var nillableContinuation: CheckedContinuation<AlertResult, Never>? = inCont
            
            let alertVC = AlertAssembly().createModule(alertModel: model,
                                                       analytics: analytics,
                                                       liveCircleManager: self.liveCircleManager) { result in
                nillableContinuation?.resume(with: .success(result))
                nillableContinuation = nil
                return
            }
            
            DispatchQueue.main.async {
                view?.contentNavigationController?.pushViewController(alertVC, animated: true)
                self.alertVC = alertVC
            }
        })
        
        return result
    }
    init(completionManager: CompletionManager,
         liveCircleManager: LiveCircleManager,
         analytics: AnalyticsManager,
         sdkManager: SDKManager,
         setupManager: SetupManager) {
        self.completionManager = completionManager
        self.liveCircleManager = liveCircleManager
        self.analytics = analytics
        self.sdkManager = sdkManager
        self.setupManager = setupManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    @MainActor
    func showLoading(with text: String? = nil,
                     animate: Bool = true) {
        alertVC?.showLoading(with: text, animate: animate)
    }
    
    @MainActor
    func hideLoading(animate: Bool = true) {
        alertVC?.hideLoading(animate: animate)
    }
    
    @MainActor
    func hide(animated: Bool = true, completion: Action? = nil) {
        alertVC?.contentNavigationController?.popViewController(animated: animated,
                                                                completion: completion)
        alertVC = nil
    }
    
    private var alertViewNeeded: Bool {
        
        setupManager.resultViewNeeded
    }
}
