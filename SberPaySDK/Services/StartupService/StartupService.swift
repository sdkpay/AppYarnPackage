//
//  StartupService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 12.11.2022.
//

import UIKit

let closeSDKNotification = "CloseSDK"

protocol StartupService {
    func openInitialScreen(with manager: SDKManager, analytics: AnalyticsService)
}

final class DefaultStartupService: StartupService {
    private var sdkWindow: TransparentWindow?
    private var manager: SDKManager?
    private var analytics: AnalyticsService?
    
    func openInitialScreen(with manager: SDKManager, analytics: AnalyticsService) {
        setupWindows()
        guard let sdkWindow = sdkWindow else { return }
        self.manager = manager
        sdkWindow.rootViewController = RootVC(manager: manager, analytics: analytics)
        analytics.sendEvent(.BankAppFound)
        self.analytics = analytics
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
}
