//
//  PaymentModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

final class PaymentModuleAssembly {
    
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(with mode: PaymentVCMode, router: PaymentRouting) -> ModuleVC {
        
        let presenter = modulePresenter(router, mode: mode)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting, mode: PaymentVCMode) -> PaymentModulePresenting {
        PaymentModulePresenter(router,
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
                               featureToggle: locator.resolve(),
                               vcMode: mode,
                               otpService: locator.resolve())
    }

    private func moduleView(presenter: PaymentModulePresenting) -> ModuleVC & IPaymentModuleVC {
        
        let view = PaymentModuleVC(presenter)
        presenter.view = view
        return view
    }
}
