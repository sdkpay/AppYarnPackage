//
//  AuthRouter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol AuthRouting {
    func presentPayment()
}

final class AuthRouter: AuthRouting {
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    func presentPayment() {
//        DEBUG
//        let vc = PaymentAssembly(locator: locator).createModule()
//        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
        let vc = PartPayAssembly(locator: locator).createModule { card in
        }
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
