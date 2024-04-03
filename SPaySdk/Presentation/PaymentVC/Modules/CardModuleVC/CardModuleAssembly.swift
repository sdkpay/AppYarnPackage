//
//  CardModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.04.2024.
//

import UIKit

final class CardModuleAssembly {
    
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
    
    func modulePresenter(_ router: PaymentRouting) -> CardModulePresenting {
        
        CardModulePresenter(router,
                            manager: locator.resolve(),
                            userService: locator.resolve(),
                            analytics: locator.resolve(),
                            bankManager: locator.resolve(),
                            paymentService: locator.resolve(),
                            locationManager: locator.resolve(),
                            completionManager: locator.resolve(),
                            alertService: locator.resolve(),
                            authService: locator.resolve(),
                            partPayService: locator.resolve(),
                            secureChallengeService: locator.resolve(),
                            authManager: locator.resolve(),
                            biometricAuthProvider: locator.resolve(),
                            payAmountValidationManager: locator.resolve(),
                            featureToggle: locator.resolve(),
                            otpService: locator.resolve())
    }

    private func moduleView(presenter: CardModulePresenting) -> ModuleVC & ICardModuleVC {
        
        let view = CardModuleVC(presenter)
        return view
    }
}

