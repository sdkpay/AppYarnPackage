//
//  StartupService.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SberPaySDK

final class StartupService {
    func setupInitialState(with window: UIWindow) {
        window.rootViewController = UINavigationController(rootViewController: RootVC())
        window.makeKeyAndVisible()
    }
}
