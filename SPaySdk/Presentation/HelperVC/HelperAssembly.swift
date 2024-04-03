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
    
    @MainActor
    func createModule(transition: Transition) {
        let router = moduleRouter()
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        transition.performTransition(for: contentView)
    }
    
    private func moduleRouter() -> HelperRouter {
        HelperRouter(with: locator.resolve())
    }

    private func modulePresenter(_ router: HelperRouter) -> HelperPresenter {
        HelperPresenter(router,
                        completionManager: locator.resolve(),
                        userService: locator.resolve(),
                        bankAppManager: locator.resolve(),
                        featureToggle: locator.resolve(),
                        helperConfigManager: locator.resolve())
    }

    private func moduleView(presenter: HelperPresenter) -> ContentVC & IHelperVC {
        let view = HelperVC(presenter, analytics: locator.resolve())
        presenter.view = view
        return view
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
