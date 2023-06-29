//
//  StartupService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 12.11.2022.
//

import UIKit

let closeSDKNotification = "CloseSDKWithoutError"
let closeSDKNotificationWithError = "CloseSDKWithError"

protocol StartupService {
    func openInitialScreen(with viewController: UIViewController,
                           with locator: LocatorService)
    func completePayment(paymentSuccess: SPayState,
                         completion: @escaping Action)
}

final class DefaultStartupService: StartupService {
    private var sdkWindow: TransparentWindow?
    private var locator: LocatorService?
    private weak var rootController: RootVC?
    private let timeManager: OptimizationCheсkerManager?
    
    init(timeManager: OptimizationCheсkerManager) {
        self.timeManager = timeManager
    }

    func openInitialScreen(with viewController: UIViewController,
                           with locator: LocatorService) {
        let rootVC = RootAssembly(locator: locator).createModule()
        rootController = rootVC
        setupWindows(viewController: viewController, locator: locator, rootVC: rootVC)
        self.locator = locator
        let analytics: AnalyticsService = locator.resolve()
        analytics.sendEvent(.BankAppFound)
        setenv("CFNETWORK_DIAGNOSTICS", "3", 1)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeSdk),
                                               name: Notification.Name(closeSDKNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeSdk(isErrorCompleted:)),
                                               name: Notification.Name(closeSDKNotificationWithError),
                                               object: true)
    }
    
    private func setupWindows(viewController: UIViewController,
                              locator: LocatorService,
                              rootVC: UIViewController) {
        rootVC.modalPresentationStyle = .custom
        viewController.present(rootVC, animated: true)
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    @objc
    private func closeSdk(isErrorCompleted: Bool = false) {
        guard let locator = locator else { return }
        let network: NetworkService = locator.resolve()
        network.cancelTask()
        if !isErrorCompleted {
            let manager: SDKManager = locator.resolve()
            manager.completionWithError(error: .cancelled)
        }
        let analytics: AnalyticsService = locator.resolve()
        analytics.sendEvent(.ManuallyClosed)
        rootController?.dismiss(animated: true)
        sdkWindow = nil
        timeManager?.stopContectionTypeChecking()
    }
    
    func completePayment(paymentSuccess: SPayState,
                         completion: @escaping Action) {
        guard let locator = locator
        else { return }
        let service: AlertService = locator.resolve()
        
        switch paymentSuccess {
        case .success:
            service.showAlert(on: sdkWindow?.topVC as? ContentVC,
                              with: Strings.Alert.Pay.Success.title,
                              state: .success,
                              buttons: [],
                              completion: completion)
        case .waiting:
            let button = AlertButtonModel(title: Strings.Ok.title,
                                          type: .full,
                                          action: completion)
            service.showAlert(on: sdkWindow?.topVC as? ContentVC,
                              with: ConfigGlobal.localization?.payLoading ?? "",
                              state: .waiting,
                              buttons: [button],
                              completion: {})
        case .error:
            service.showAlert(on: sdkWindow?.topVC as? ContentVC,
                              with: Strings.Alert.Error.Main.title,
                              state: .failure,
                              buttons: [],
                              completion: completion)
        }
    
        closeSdk()
    }
}
