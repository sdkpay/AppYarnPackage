//
//  StartupService.swift
//  SPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdk

final class StartupService {
    func setupInitialState(with window: UIWindow) {
        window.rootViewController = UINavigationController(rootViewController: RootVC())
        window.makeKeyAndVisible()
    }
}
