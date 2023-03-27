//
//  RootRouter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol RootRouting {
    func presentAuth()
}

final class RootRouter: RootRouting {
    weak var viewController: UIViewController?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    func presentAuth() {
        let vc = AuthAssembly(locator: locator).createModule()
        let navVC = ContentNC(rootViewController: vc)
        viewController?.present(navVC, animated: true, completion: nil)
    }
}
