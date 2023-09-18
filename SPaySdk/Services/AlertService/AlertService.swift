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
            let service: AlertService = DefaultAlertService(liveCircleManager: container.resolve())
            return service
        })
    }
}

protocol AlertService {
    func showAlert(on view: ContentVC?,
                   with text: String,
                   state: AlertState,
                   buttons: [AlertButtonModel],
                   completion: @escaping Action)
    func show(on view: ContentVC?, type: AlertType)
    func showLoading(with text: String?,
                     animate: Bool)
    func hideLoading(animate: Bool)
    func hide(animated: Bool, completion: Action?)
    func close(animated: Bool, completion: Action?)
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
    func close(animated: Bool = true, completion: Action? = nil) {
        close(animated: animated, completion: completion)
    }
}

final class DefaultAlertService: AlertService {
    private var alertVC: ContentVC?
    private let liveCircleManager: LiveCircleManager
    
    init(liveCircleManager: LiveCircleManager) {
        self.liveCircleManager = liveCircleManager
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func showAlert(on view: ContentVC?,
                   with text: String,
                   state: AlertState,
                   buttons: [AlertButtonModel],
                   completion: @escaping Action) {
        DispatchQueue.main.async {
            let model = AlertViewModel(image: state.image,
                                       title: text,
                                       buttons: buttons,
                                       sound: state.soundPath,
                                       feedBack: state.feedBack,
                                       completion: completion)
            let alertVC = AlertAssembly().createModule(alertModel: model,
                                                       liveCircleManager: self.liveCircleManager)
            view?.contentNavigationController?.pushViewController(alertVC, animated: true)
            self.alertVC?.contentNavigationController?.popViewController(animated: false)
            self.alertVC = alertVC
        }
    }
    
    func showLoading(with text: String? = nil,
                     animate: Bool = true) {
        alertVC?.showLoading(with: text, animate: animate)
    }
    
    func hideLoading(animate: Bool = true) {
        alertVC?.hideLoading(animate: animate)
    }
    
    func show(on view: ContentVC?, type: AlertType) {
        switch type {
        case .paySuccess(let completion):
            showAlert(on: view,
                      with: Strings.Alert.Pay.Success.title,
                      state: .success,
                      buttons: [],
                      completion: completion)
        case .defaultError(let completion):
            showAlert(on: view,
                      with: Strings.Alert.Error.Main.title,
                      state: .failure,
                      buttons: [],
                      completion: completion)
        case let .noInternet(retry, completion):
            let tryButton = AlertButtonModel(title: Strings.Try.title,
                                             type: .full,
                                             action: retry)
            let cancelButton = AlertButtonModel(title: Strings.Cancel.title,
                                                type: .cancel,
                                                action: completion)
            showAlert(on: view,
                      with: Strings.Alert.Pay.No.Internet.title,
                      state: .warning,
                      buttons:
                        [
                            tryButton,
                            cancelButton
                        ],
                      completion: completion)
        case let .partPayError(fullPay: fullPay, back: back):
            let fullPayButton = AlertButtonModel(title: Strings.Pay.Full.title,
                                                 type: .full,
                                                 action: fullPay)
            let returnButton = AlertButtonModel(title: Strings.Return.title,
                                                type: .clear,
                                                action: back)
            showAlert(on: view,
                      with: Strings.Alert.Pay.Error.title,
                      state: .failure,
                      buttons: [
                        fullPayButton,
                        returnButton
                      ],
                      completion: back)
        case .tryingError(back: let back):
            let fullPayButton = AlertButtonModel(title: Strings.Return.title,
                                                 type: .full,
                                                 action: back)
            showAlert(on: view,
                      with: Strings.Error.trying,
                      state: .failure,
                      buttons: [
                        fullPayButton
                      ],
                      completion: back)
        }
    }
    
    func hide(animated: Bool = true, completion: Action? = nil) {
        alertVC?.contentNavigationController?.popViewController(animated: animated,
                                                                completion: completion)
        alertVC = nil
    }
    
    func close(animated: Bool = true, completion: Action? = nil) {
        alertVC?.dismiss(animated: animated, completion: completion)
    }
    
    func cancelFeedback() {
        
    }
}
