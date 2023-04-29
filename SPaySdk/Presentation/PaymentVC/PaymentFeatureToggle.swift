//
//  PaymentFeatureToggle.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.04.2023.
//

import Foundation

protocol PaymentFeatureToggle {
    func modulePresenter(_ router: PaymentRouting, locator: LocatorService) -> PaymentPresenter
}

extension PaymentFeatureToggle where Self: PaymentAssembly {
    func defaultModulePresenter(_ router: PaymentRouting, locator: LocatorService) -> PaymentPresenter {
        PaymentPresenter(router,
                         manager: locator.resolve(),
                         userService: locator.resolve(),
                         analytics: locator.resolve(),
                         bankManager: locator.resolve(),
                         paymentService: locator.resolve(),
                         locationManager: locator.resolve(),
                         alertService: locator.resolve(),
                         timeManager: OptimizationCheсkerManager())
    }
}

extension PaymentFeatureToggle where Self: PaymentAssembly {
    func partPayModulePresenter(_ router: PaymentRouting, locator: LocatorService) -> PaymentPresenter {
        PaymentPresenter(router,
                         manager: locator.resolve(),
                         userService: locator.resolve(),
                         analytics: locator.resolve(),
                         bankManager: locator.resolve(),
                         paymentService: locator.resolve(),
                         locationManager: locator.resolve(),
                         alertService: locator.resolve(),
                         partPayService: locator.resolve(),
                         timeManager: OptimizationCheсkerManager())
    }
}

extension PaymentFeatureToggle where Self: PaymentAssembly {
    func modulePresenter(_ router: PaymentRouting, locator: LocatorService) -> PaymentPresenter {
        let featureToggleService = locator.resolve(FeatureToggleService.self)
        switch featureToggleService.isEnabled(.bnpl) {
        case true: return defaultModulePresenter(router, locator: locator)
        case false: return partPayModulePresenter(router, locator: locator)
        }
    }
}
