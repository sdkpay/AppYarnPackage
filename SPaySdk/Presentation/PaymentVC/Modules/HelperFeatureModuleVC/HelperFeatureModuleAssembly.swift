//
//  HelperFeatureModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import Foundation

final class HelperFeatureModuleAssembly {
    
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(router: PaymentRouting) -> ModuleVC {
        
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting) -> HelperFeatureModulePresenting {
        HelperFeatureModulePresenter(router,
                                     manager: locator.resolve(),
                                     userService: locator.resolve(),
                                     analytics: locator.resolve(),
                                     bankManager: locator.resolve(),
                                     completionManager: locator.resolve(),
                                     alertService: locator.resolve(),
                                     authService: locator.resolve(),
                                     secureChallengeService: locator.resolve(),
                                     authManager: locator.resolve(),
                                     biometricAuthProvider: locator.resolve(),
                                     partPayService: locator.resolve(),
                                     helperConfigManager: locator.resolve())
    }

    private func moduleView(presenter: HelperFeatureModulePresenting) -> ModuleVC & IHelperFeatureModuleVC {
        
        let view = HelperFeatureModuleVC(presenter)
        return view
    }
}
