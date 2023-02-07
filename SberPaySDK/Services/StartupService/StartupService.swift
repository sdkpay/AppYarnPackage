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
                         completion: Action)
}

final class DefaultStartupService: StartupService {
    private var sdkWindow: TransparentWindow?
    private var manager: SDKManager?
    private var analytics: AnalyticsService?
    
    func openInitialScreen(with locator: LocatorService) {
        setupWindows()
        guard let sdkWindow = sdkWindow else { return }
        self.manager = locator.resolve()
        sdkWindow.rootViewController = RootAssembly(locator: locator).createModule()
        self.analytics = locator.resolve()
        analytics?.sendEvent(.BankAppFound)
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
        sdkWindow = nil
        manager?.completionWithError(error: .cancelled)
        analytics?.sendEvent(.ManuallyClosed)
        manager = nil
    }
    
    func completePayment(paymentSuccess: Bool,
                         completion: Action) {
        // DEBUG
        guard let topVC = sdkWindow?.topVC as? ContentVC else { return }
        topVC.showAlert(with: paymentSuccess ? .success : .failure())
        completion()
        closeSdk()
    }
}
