//
//  StartupService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 12.11.2022.
//

import UIKit

let closeSDKNotification = "CloseSDK"

protocol StartupService {
    func openInitialScreen(with locator: LocatorService)
    func completePayment(paymentSuccess: Bool,
                         completion: @escaping Action)
}

final class DefaultStartupService: StartupService {
    private var sdkWindow: TransparentWindow?
    private var locator: LocatorService?
    
    func openInitialScreen(with locator: LocatorService) {
        setupWindows()
        guard let sdkWindow = sdkWindow else { return }
        self.locator = locator
        sdkWindow.rootViewController = RootAssembly(locator: locator).createModule()
        let analytics: AnalyticsService = locator.resolve()
        analytics.sendEvent(.BankAppFound)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeSdk),
                                               name: Notification.Name(closeSDKNotification),
                                               object: nil)
    }
    
    private func setupWindows() {
        guard let appWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        if sdkWindow == nil {
            sdkWindow = TransparentWindow(frame: appWindow.bounds)
            sdkWindow?.windowLevel = UIWindow.Level.alert + 1
            sdkWindow?.makeKeyAndVisible()
        }
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
        sdkWindow = nil
    }
    
    func completePayment(paymentSuccess: Bool,
                         completion: @escaping Action) {
        // DEBUG
        guard let topVC = sdkWindow?.topVC as? ContentVC else { return }
        topVC.showAlert(with: paymentSuccess ? .success : .failure()) {
            completion()
        }
        closeSdk()
    }
}
