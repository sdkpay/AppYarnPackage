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

    func createModule() -> ContentVC {
        let router = moduleRouter()
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        router.viewController = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting) -> PaymentPresenter {
        PaymentPresenter(router,
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
                         authManager: locator.resolve(),
                         biometricAuthProvider: locator.resolve(),
                         featureToggle: locator.resolve(),
                         otpService: locator.resolve(),
                         timeManager: OptimizationCheсkerManager())
    }

    func moduleRouter() -> PaymentRouter {
        PaymentRouter(with: locator)
    }

    private func moduleView(presenter: PaymentPresenter) -> ContentVC & IPaymentVC {
        let view = PaymentVC(presenter)
        presenter.view = view
        return view
    }
}
