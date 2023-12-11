//
//  PaymentAssembly.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class PaymentAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(with state: PaymentVCMode) -> ContentVC {
        let router = moduleRouter()
        let presenter = modulePresenter(router, with: state)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        router.viewController = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting,
                         with state: PaymentVCMode) -> PaymentPresenter {
        
        var paymentVCMode: PaymentViewModel
        
        switch state {
            
        case .pay:
            paymentVCMode = PaymentViewPayModel(userService: locator.resolve(),
                                                featureToggle: locator.resolve(),
                                                partPayService: locator.resolve(),
                                                payAmountValidationManager: locator.resolve())
        case .helper:
            paymentVCMode = PaymentViewHelpModel(userService: locator.resolve(),
                                                 featureToggle: locator.resolve(),
                                                 helperConfigManager: locator.resolve())
        }
        
        return PaymentPresenter(router,
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
                                otpService: locator.resolve(),
                                timeManager: OptimizationCheсkerManager(),
                                paymentViewModel: paymentVCMode, 
                                mode: state)
    }

    func moduleRouter() -> PaymentRouter {
        PaymentRouter(with: locator)
    }

    private func moduleView(presenter: PaymentPresenter) -> ContentVC & IPaymentMasterVC {
        let view = PaymentMasterVC(presenter)
        presenter.view = view
        return view
    }
}
