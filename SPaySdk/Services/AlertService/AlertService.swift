//
//  AlertService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 27.02.2023.
//

import UIKit

struct AlertViewModel {
    let image: UIImage?
    let title: String
    let buttons: [(title: String,
                   type: DefaultButtonAppearance,
                   action: Action)]
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
}

final class AlertServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: AlertService = DefaultAlertService(locator: container)
        container.register(service: service)
    }
}

protocol AlertService {
    func showAlert(on view: ContentVC?,
                   with text: String,
                   state: AlertState,
                   buttons: [(title: String,
                              type: DefaultButtonAppearance,
                              action: Action)],
                   completion: @escaping Action)
    func show(on view: ContentVC?, type: AlertType)
}

final class DefaultAlertService: AlertService {
    private let locator: LocatorService
    
    init(locator: LocatorService) {
        self.locator = locator
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    private var vc: ContentVC? {
        var navigationController: ContentNC
        if #available(iOS 13.0, *) {
            guard let nc = UIApplication.shared.topViewController as? ContentNC
            else { return nil }
            navigationController = nc
        } else {
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) as? TransparentWindow,
                  let nc = window.topVC as? ContentNC
            else { return nil }
            navigationController = nc
        }
        
        return navigationController.topViewController as? ContentVC
    }
    
    func showAlert(on view: ContentVC?,
                   with text: String,
                   state: AlertState,
                   buttons: [(title: String,
                              type: DefaultButtonAppearance,
                              action: Action)],
                   completion: @escaping Action) {
        let model = AlertViewModel(image: state.image,
                                   title: text,
                                   buttons: buttons,
                                   sound: state.soundPath,
                                   feedBack: state.feedBack,
                                   completion: completion)
        view?.showAlert(with: model)
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
            var buttons: [(title: String,
                           type: DefaultButtonAppearance,
                           action: Action)] = []
                   buttons.append((title: .Common.tryTitle,
                                   type: .full,
                                   action: retry))
                   buttons.append((title: .Common.cancelTitle,
                                   type: .cancel,
                                   action: completion))
            showAlert(on: view,
                      with: .Alert.alertPayNoInternetTitle,
                      state: .failure,
                      buttons: buttons,
                      completion: completion)
        }
    }
}
