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
    let action: Action?
}

struct AlertViewModel {
    let image: UIImage?
    let title: String
    let subtite: String?
    let cost: String?
    let buttons: [AlertButtonModel]
    let sound: String
    let feedBack: UINotificationFeedbackGenerator.FeedbackType
    let isFailure: Bool
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
    case paySuccess
    case defaultError
    case noInternet
    case partPayError
    case tryingError
    case noMoney
}

final class AlertServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(AlertService.self)
    
    func register(in container: LocatorService) {
        container.register(reference: {
            let service: AlertService = DefaultAlertService(completionManager: container.resolve(),
                                                            liveCircleManager: container.resolve(),
                                                            analytics: container.resolve())
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
    private let analytics: AnalyticsService
    private let liveCircleManager: LiveCircleManager
    
    @MainActor
    @discardableResult
    func show(on view: ContentVC?, type: AlertType) async -> AlertResult {
        
        switch type {
        case .paySuccess:
            
            analytics.sendEvent(.LCStatusSuccessViewAppeared)
            
            return await show(on: view,
                              with: Strings.Alert.Pay.Success.title,
                              with: nil,
                              state: .success,
                              buttons: [])
        case .defaultError:
            
            analytics.sendEvent(.LCStatusErrorViewAppeared, with: "error: default")
            
            return await show(on: view,
                              with: Strings.Alert.Error.Main.title,
                              with: Strings.Alert.Error.Main.subtitle,
                              state: .warning,
                              buttons: [])
        case .noInternet:
            
            analytics.sendEvent(.LCStatusErrorViewAppeared, with: "errror: noInternet")
            
            let tryButton = AlertButtonModel(title: Strings.Try.title,
                                             type: .blackBack,
                                             action: nil)
            let cancelButton = AlertButtonModel(title: Strings.Cancel.title,
                                                type: .info,
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
            
            analytics.sendEvent(.LCStatusErrorViewAppeared, with: "error: partPayError")
            
            let fullPayButton = AlertButtonModel(title: Strings.Pay.Full.title,
                                                 type: .blackBack,
                                                 action: nil)
            let returnButton = AlertButtonModel(title: Strings.Return.title,
                                                type: .info,
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
            
            analytics.sendEvent(.LCStatusErrorViewAppeared)
            
            let fullPayButton = AlertButtonModel(title: Strings.Button.Otp.back,
                                                 type: .blackBack,
                                                 action: nil)
            
            return await show(on: view,
                              with: Strings.Error.trying,
                              with: nil,
                              state: .failure,
                              buttons: [
                                fullPayButton
                              ])
        case .noMoney:
            
            let cancel = AlertButtonModel(title: Strings.Return.title,
                                          type: .cancel,
                                          action: nil)
            return await show(on: view,
                              with: Strings.Error.NoMoney.title,
                              with: Strings.Error.NoMoney.subtitle,
                              state: .failure,
                              buttons: [
                                cancel
                              ])
        }
    }
    
    @MainActor
    @discardableResult
    func show(on view: ContentVC?,
              with text: String,
              with subtitle: String?,
              with cost: String? = nil,
              state: AlertState,
              buttons: [AlertButtonModel]) async -> AlertResult {
        
        let model = AlertViewModel(image: state.image,
                                   title: text,
                                   subtite: subtitle,
                                   cost: cost,
                                   buttons: buttons,
                                   sound: state.soundPath,
                                   feedBack: state.feedBack,
                                   isFailure: state != .success)
        
        let result = await withCheckedContinuation({( inCont: CheckedContinuation<AlertResult, Never>) -> Void in
            
            let alertVC = AlertAssembly().createModule(alertModel: model,
                                                       liveCircleManager: self.liveCircleManager) { result in
                inCont.resume(with: .success(result))
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
         analytics: AnalyticsService) {
        self.completionManager = completionManager
        self.liveCircleManager = liveCircleManager
        self.analytics = analytics
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
}
