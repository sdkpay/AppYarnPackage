//
//  AuthRouter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol AuthRouting {
    func presentPayment()
    func presentBankAppPicker(completion: @escaping Action)
    func presentFakeScreen(completion: @escaping () -> Void)
}

final class AuthRouter: AuthRouting {
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor
    func presentPayment() {
        let vc = PaymentAssembly(locator: locator).createModule()
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
    
    @MainActor
    func presentBankAppPicker(completion: @escaping Action) {
        let vc = BankAppPickerAssembly(locator: locator).createModule(completion: completion)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
    
    @MainActor
    func presentFakeScreen(completion: @escaping () -> Void) {
        let fakeViewController = FakeViewController()
        viewController?.present(fakeViewController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            fakeViewController.dismiss(animated: true, completion: completion)
        }
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
