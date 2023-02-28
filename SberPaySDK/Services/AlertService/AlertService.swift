//
//  AlertService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 27.02.2023.
//

import UIKit

struct AlertViewModel {
    let image: UIImage?
    let title: String
    let buttons: [(title: String,
                   type: DefaultButtonAppearance,
                   action: Action,
                   closeButton: Bool)]
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

final class AlertServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: AlertService = DefaultAlertService(locator: container)
        container.register(service: service)
    }
}

protocol AlertService {
    func showAlert(with text: String,
                   state: AlertState,
                   buttons: [(title: String,
                              type: DefaultButtonAppearance,
                              action: Action,
                              closeButton: Bool)],
                   completion: @escaping Action)
    func showNoInternet(retry: @escaping Action, cancel: @escaping Action)
}

final class DefaultAlertService: AlertService {
    private let locator: LocatorService
    
    init(locator: LocatorService) {
        self.locator = locator
    }
    
    private var vc: ContentVC? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) as? TransparentWindow,
              let nc = window.topVC as? ContentNC
        else { return nil }
        return nc.topViewController as? ContentVC
    }
    
    func showAlert(with text: String,
                   state: AlertState,
                   buttons: [(title: String,
                              type: DefaultButtonAppearance,
                              action: Action,
                              closeButton: Bool)],
                   completion: @escaping Action) {
        let model = AlertViewModel(image: state.image,
                                   title: text,
                                   buttons: buttons,
                                   sound: state.soundPath,
                                   feedBack: state.feedBack,
                                   completion: completion)
        vc?.showAlert(with: model)
    }
    
    func showNoInternet(retry: @escaping Action, cancel: @escaping Action) {
        var buttons: [(title: String,
                       type: DefaultButtonAppearance,
                       action: Action,
                       closeButton: Bool)] = []
               buttons.append((title: .Common.tryTitle,
                               type: .full,
                               action: retry,
                               closeButton: false))
               buttons.append((title: .Common.cancelTitle,
                               type: .cancel,
                               action: cancel,
                               closeButton: true))
        showAlert(with: .Alert.alertPayNoInternetTitle,
                  state: .failure,
                  buttons: buttons,
                  completion: cancel)
    }
}
