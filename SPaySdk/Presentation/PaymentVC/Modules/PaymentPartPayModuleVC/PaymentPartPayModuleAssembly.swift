//
//  PaymentPartPayModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import Foundation

final class PaymentPartPayModuleAssembly {
    
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
    
    func modulePresenter(_ router: PaymentRouting) -> PaymentPartPayModulePresenting {
        PaymentPartPayModulePresenter(router,
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
                                      featureToggle: locator.resolve(),
                                      otpService: locator.resolve())
    }

    private func moduleView(presenter: PaymentPartPayModulePresenting) -> ModuleVC & IPaymentPartPayModuleVC {
        
        let view = PaymentPartPayModuleVC(presenter)
        presenter.view = view
        return view
    }
}
