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

    func moduleRouter() -> PaymentRouter {
        PaymentRouter(with: locator)
    }

    private func modulePresenter(_ router: PaymentRouting) -> PaymentPresenter {
        let presenter = PaymentPresenter(router,
                                         manager: locator.resolve(),
                                         userService: locator.resolve(),
                                         analytics: locator.resolve(),
                                         paymentService: locator.resolve(),
                                         locationManager: locator.resolve(),
                                         alertService: locator.resolve())
        return presenter
    }

    private func moduleView(presenter: PaymentPresenter) -> ContentVC & IPaymentVC {
        let view = PaymentVC(presenter)
        presenter.view = view
        return view
    }
}
