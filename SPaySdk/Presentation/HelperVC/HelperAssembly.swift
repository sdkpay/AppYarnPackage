//
//  HelperAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 19.11.2023.
//

import UIKit

final class HelperAssembly {
    
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }
    
    func createModule() -> ContentVC {
        let router = moduleRouter()
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func moduleRouter() -> HelperRouter {
        HelperRouter(with: locator)
    }

    private func modulePresenter(_ router: HelperRouter) -> HelperPresenter {
        HelperPresenter(router,
                        completionManager: locator.resolve(),
                        userService: locator.resolve(),
                        bankAppManager: locator.resolve(),
                        featureToggle: locator.resolve(),
                        helperConfigManager: locator.resolve(),
                        analytics: locator.resolve())
    }

    private func moduleView(presenter: HelperPresenter) -> ContentVC & IHelperVC {
        let view = HelperVC(presenter)
        presenter.view = view
        return view
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
