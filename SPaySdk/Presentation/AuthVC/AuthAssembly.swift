//
//  AuthAssembly.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class AuthAssembly {
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
    
    func moduleRouter() -> AuthRouter {
        AuthRouter(with: locator)
    }

    private func modulePresenter(_ router: AuthRouter) -> AuthPresenter {
        AuthPresenter(router,
                      authService: locator.resolve(),
                      sdkManager: locator.resolve(),
                      analytics: locator.resolve(),
                      userService: locator.resolve(),
                      alertService: locator.resolve(),
                      bankManager: locator.resolve(),
                      contentLoadManager: locator.resolve(),
                      timeManager: OptimizationCheсkerManager(),
                      enviromentManager: locator.resolve())
    }

    private func moduleView(presenter: AuthPresenter) -> ContentVC & IAuthVC {
        let view = AuthVC(presenter)
        presenter.view = view
        return view
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
