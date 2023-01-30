//
//  AuthRouter.swift
//  SberPaySDK
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
        let vc = PaymentAssembly(locator: locator).createModule()
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
