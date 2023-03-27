//
//  AppDelegate.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdk

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private lazy var startupService = StartupService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let config = getConfig()
        SBPay.debugConfig(network: config.network, ssl: config.ssl == "On")
        SBPay.setup()
        startupService.setupInitialState(with: window)
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == "sberPayExampleapp" && url.host == "sberidauth" {
            SBPay.getAuthURL(url)
        }
        return true
    }
    
    private func getConfig() -> ConfigValues {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: "ConfigValues") as? Data,
           let decoded = try? JSONDecoder().decode(ConfigValues.self, from: data) {
            return decoded
        } else {
            return ConfigValues()
        }
    }
}
