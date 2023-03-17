//
//  StartupService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 12.11.2022.
//

import UIKit

let closeSDKNotification = "CloseSDK"

protocol StartupService {
    func openInitialScreen(with viewController: UIViewController,
                           with locator: LocatorService)
    func completePayment(paymentSuccess: SBPayState,
                         completion: @escaping Action)
}

final class DefaultStartupService: StartupService {
    private var sdkWindow: TransparentWindow?
    private var locator: LocatorService?
    private var rootController: RootVC?

    func openInitialScreen(with viewController: UIViewController,
                           with locator: LocatorService) {
        let rootVC = RootAssembly(locator: locator).createModule()
        rootController = rootVC
        setupWindows(viewController: viewController, locator: locator, rootVC: rootVC)
        self.locator = locator
        let analytics: AnalyticsService = locator.resolve()
        analytics.sendEvent(.BankAppFound)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeSdk),
                                               name: Notification.Name(closeSDKNotification),
                                               object: nil)
    }
    
    private func setupWindows(viewController: UIViewController,
                              locator: LocatorService,
                              rootVC: UIViewController) {
//        if #available(iOS 13.0, *), UIApplication.shared.supportsMultipleScenes {
//            rootController.present(viewController, animated: true)
//        } else {
//            sdkWindow = TransparentWindow(frame: UIScreen.main.bounds)
//            sdkWindow?.windowLevel = UIWindow.Level.alert + 1
//            sdkWindow?.makeKeyAndVisible()
//        }

        rootController?.modalPresentationStyle = .custom
        viewController.present(rootController!, animated: true)
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    @objc
    private func closeSdk() {
        guard let locator = locator else { return }
        let network: NetworkService = locator.resolve()
        network.cancelTask()
        let manager: SDKManager = locator.resolve()
        manager.completionWithError(error: .cancelled)
        let analytics: AnalyticsService = locator.resolve()
        analytics.sendEvent(.ManuallyClosed)
        rootController?.dismiss(animated: true)
        sdkWindow = nil
    }
    
    func completePayment(paymentSuccess: SBPayState,
                         completion: @escaping Action) {
        guard let locator = locator
        else { return }
        let service: AlertService = locator.resolve()
        
        switch paymentSuccess {
        case .success:
            service.showAlert(on: sdkWindow?.topVC as? ContentVC,
                              with: .Alert.alertPaySuccessTitle,
                              state: .success,
                              buttons: [],
                              completion: completion)
        case .waiting:
            var buttons: [(title: String,
                           type: DefaultButtonAppearance,
                           action: Action)] = []
            buttons.append((title: .Common.okTitle,
                            type: .full,
                            action: completion))
            service.showAlert(on: sdkWindow?.topVC as? ContentVC,
                              with: .Alert.alertPayWaitingTitle,
                              state: .waiting,
                              buttons: buttons,
                              completion: {})
        case .error:
            service.showAlert(on: sdkWindow?.topVC as? ContentVC,
                              with: .Alert.alertErrorMainTitle,
                              state: .failure,
                              buttons: [],
                              completion: completion)
        }
    
        closeSdk()
    }
}
