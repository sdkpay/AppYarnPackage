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
            return "poz.mp3"
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
            return .Common.warning
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
}

final class AlertServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register(reference: {
            let service: AlertService = DefaultAlertService(locator: container)
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
    func hide(animated: Bool)
}

extension AlertService {
    func showLoading(with text: String? = nil,
                     animate: Bool = true) {
        showLoading(with: text, animate: animate)
    }
    func hideLoading(animate: Bool = true) {
        hideLoading(animate: animate)
    }
    func hide(animated: Bool = true) {
        hide(animated: animated)
    }
}

final class DefaultAlertService: AlertService {
    private let locator: LocatorService
    private var alertVC: ContentVC?
    
    init(locator: LocatorService) {
        self.locator = locator
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
            let alertVC = AlertAssembly().createModule(alertModel: model)
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
                      with: .Alert.alertPaySuccessTitle,
                      state: .success,
                      buttons: [],
                      completion: completion)
        case .defaultError(let completion):
            showAlert(on: view,
                      with: .Alert.alertErrorMainTitle,
                      state: .failure,
                      buttons: [],
                      completion: completion)
        case let .noInternet(retry, completion):
            let tryButton = AlertButtonModel(title: .Common.tryTitle,
                                             type: .full,
                                             action: retry)
            let cancelButton = AlertButtonModel(title: .Common.cancelTitle,
                                                type: .cancel,
                                                action: completion)
            showAlert(on: view,
                      with: .Alert.alertPayNoInternetTitle,
                      state: .failure,
                      buttons:
                        [
                            tryButton,
                            cancelButton
                        ],
                      completion: completion)
        case let .partPayError(fullPay: fullPay, back: back):
            let fullPayButton = AlertButtonModel(title: .Common.payFull,
                                                 type: .full,
                                                 action: fullPay)
            let returnButton = AlertButtonModel(title: .Common.returnTitle,
                                                type: .clear,
                                                action: back)
            showAlert(on: view,
                      with: .Alert.alertPartPayError,
                      state: .failure,
                      buttons: [
                        fullPayButton,
                        returnButton
                      ],
                      completion: back)
        }
    }
    
    func hide(animated: Bool = true) {
        alertVC?.contentNavigationController?.popViewController(animated: animated)
        alertVC = nil
    }
}
