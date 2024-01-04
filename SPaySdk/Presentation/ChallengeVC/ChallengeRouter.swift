//
//  ChallengeRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import UIKit

protocol ChallengeRouting {

    func presentOTPScreen(completion: @escaping Action)
    func presentBankAppPicker(completion: @escaping Action)
}

final class ChallengeRouter: ChallengeRouting, UrlOpenable {
    
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }

    @MainActor
    func presentOTPScreen(completion: @escaping Action) {
        DispatchQueue.main.async {
            let vc = OtpAssembly(locator: self.locator).createModule(completion: completion)
            self.viewController?.contentNavigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @MainActor
    func presentBankAppPicker(completion: @escaping Action) {
        let vc = BankAppPickerAssembly(locator: locator).createModule(completion: completion)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
