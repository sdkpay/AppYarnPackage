//
//  HelperRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.12.2023.
//

import UIKit

protocol HelperRouting: UrlOpenable {
    
    func presentBankAppPicker(completion: @escaping Action)
}

final class HelperRouter: HelperRouting {
    
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor
    func presentBankAppPicker(completion: @escaping Action) {
        let vc = BankAppPickerAssembly(locator: locator).createModule(completion: completion)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
