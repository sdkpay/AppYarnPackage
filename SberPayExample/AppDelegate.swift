//
//  AppDelegate.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdkDEBUG

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private lazy var startupService = StartupService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        startupService.setupInitialState(with: window)
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if SPay.isSPayUri(url) {
            SPay.getAuthURL(url)
        } else {
            // ...
        }
        return true
    }
}
