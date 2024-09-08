//
//  AppDelegate.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdkDEBUG
import SberIdSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private lazy var startupService = StartupService()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        startupService.setupInitialState(with: window)
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        SPay.getAuthURL(url)
//        if url.scheme == "testapp" && url.host == "test" {
//            SPay.getAuthURL(url)
//        }
        
//        if url.scheme == "testapp" && url.host == "spay" {
//            SIDManager.getResponseFrom(url) { response in
//                
//                let status = response.isSuccess ? "✅" : "❌"
//                
//                let text: [String: String] = [
//                    "appToken": response.appToken ?? "none",
//                    "state": response.state ?? "none",
//                    "nonce": response.nonce,
//                    "authCode": response.authCode ?? "none",
//                    "error": response.error ?? "none"
//                ]
//
//                 showAlert(title: "SID auth \(status)",
//                           text: text.json)
//            }
//        }
        
        return true
    }
    
    private func showAlert(title: String, text: String) {
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
                
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in 
            topWindow?.isHidden = true
            topWindow = nil
        }))
        
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension Collection {
    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return "json serialization error: \(error)"
        }
    }
}
