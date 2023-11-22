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
    let action: Action
}

struct AlertViewModel {
    let image: UIImage?
    let title: String
    let subtite: String?
    let cost: String?
    let buttons: [AlertButtonModel]
    let sound: String
    let feedBack: UINotificationFeedbackGenerator.FeedbackType
    let completion: Action
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
    case paySuccess(completion: Action)
    case defaultError(completion: Action)
    case noInternet(retry: Action, completion: Action)
    case partPayError(fullPay: Action, back: Action)
    case tryingError(back: Action)
}

final class AlertServiceAssembly: Assembly {
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
    func showAlert(on view: ContentVC?,
                   with text: String,
                   with subtitle: String?,
                   with cost: String?,
                   state: AlertState,
                   buttons: [AlertButtonModel],
                   completion: @escaping Action)
    func show(on view: ContentVC?, type: AlertType)
    func showLoading(with text: String?,
                     animate: Bool)
    func hideLoading(animate: Bool)
    func hide(animated: Bool, completion: Action?)
    func close()
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

final class DefaultAlertService: AlertService {
    private let completionManager: CompletionManager
    
    private var alertVC: ContentVC?
    private let analytics: AnalyticsService
    private let liveCircleManager: LiveCircleManager
    
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
    func showAlert(on view: ContentVC?,
                   with text: String,
                   with subtitle: String?,
                   with cost: String? = nil,
                   state: AlertState,
                   buttons: [AlertButtonModel],
                   completion: @escaping Action) {
        DispatchQueue.main.async {
            let model = AlertViewModel(image: state.image,
                                       title: text,
                                       subtite: subtitle,
                                       cost: cost,
                                       buttons: buttons,
                                       sound: state.soundPath,
                                       feedBack: state.feedBack,
                                       completion: completion)
            let alertVC = AlertAssembly().createModule(alertModel: model,
                                                       liveCircleManager: self.liveCircleManager)
            view?.contentNavigationController?.pushViewController(alertVC, animated: true)
            self.alertVC?.contentNavigationController?.popViewController(animated: true)
            self.alertVC = alertVC
        }
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
    func show(on view: ContentVC?, type: AlertType) {
        switch type {
        case .paySuccess(let completion):
            analytics.sendEvent(.LCStatusSuccessViewAppeared)
            showAlert(on: view,
                      with: Strings.Alert.Pay.Success.title,
                      with: nil,
                      state: .success,
                      buttons: [],
                      completion: completion)
        case .defaultError(let completion):
            analytics.sendEvent(.LCStatusErrorViewAppeared, with: "error: default")
            showAlert(on: view,
                      with: Strings.Alert.Error.Main.title,
                      with: Strings.Alert.Error.Main.subtitle,
                      state: .warning,
                      buttons: [],
                      completion: completion)
        case let .noInternet(retry, completion):
            analytics.sendEvent(.LCStatusErrorViewAppeared, with: "errror: noInternet")
            let tryButton = AlertButtonModel(title: Strings.Try.title,
                                             type: .full,
                                             action: retry)
            let cancelButton = AlertButtonModel(title: Strings.Cancel.title,
                                                type: .cancel,
                                                action: completion)
            showAlert(on: view,
                      with: Strings.Alert.Pay.No.Internet.title,
                      with: Strings.Alert.Pay.No.Internet.subtitle,
                      state: .warning,
                      buttons:
                        [
                            tryButton,
                            cancelButton
                        ],
                      completion: completion)
        case let .partPayError(fullPay: fullPay, back: back):
            analytics.sendEvent(.LCStatusErrorViewAppeared, with: "error: partPayError")
            let fullPayButton = AlertButtonModel(title: Strings.Pay.Full.title,
                                                 type: .full,
                                                 action: fullPay)
            let returnButton = AlertButtonModel(title: Strings.Return.title,
                                                type: .clear,
                                                action: back)
            showAlert(on: view,
                      with: Strings.Alert.Pay.Error.title,
                      with: nil,
                      state: .failure,
                      buttons: [
                        fullPayButton,
                        returnButton
                      ],
                      completion: back)
        case .tryingError(back: let back):
            analytics.sendEvent(.LCStatusErrorViewAppeared)
            let fullPayButton = AlertButtonModel(title: Strings.Button.Otp.back,
                                                 type: .full,
                                                 action: back)
            showAlert(on: view,
                      with: Strings.Error.trying,
                      with: nil,
                      state: .failure,
                      buttons: [
                        fullPayButton
                      ],
                      completion: back)
        }
    }
    
    @MainActor
    func hide(animated: Bool = true, completion: Action? = nil) {
        alertVC?.contentNavigationController?.popViewController(animated: animated,
                                                                completion: completion)
        alertVC = nil
    }
    
    @MainActor
    func close() {
        completionManager.dismissCloseAction(alertVC)
    }
}
