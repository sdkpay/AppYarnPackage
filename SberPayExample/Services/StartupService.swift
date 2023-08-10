//
//  StartupService.swift
//  SPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdkDEBUG
//import IQKeyboardManagerSwift

final class StartupService {
    func setupInitialState(with window: UIWindow) {
        setupKeyboard()
        window.rootViewController = UINavigationController(rootViewController: ConfigAssembly().createModule())
        window.makeKeyAndVisible()
    }
    
    private func setupKeyboard() {
//         IQKeyboardManager.shared.enable = true
    }
}
