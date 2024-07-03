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
    
    @MainActor
    func createModule(transition: Transition) {
        let router = moduleRouter()
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        router.viewController = contentView
        transition.performTransition(for: contentView)
    }
    
    private func moduleRouter() -> AuthRouter {
        AuthRouter(with: locator.resolve())
    }

    private func modulePresenter(_ router: AuthRouter) -> AuthPresenter {
        AuthPresenter(router,
                      authService: locator.resolve(), 
                      seamlessAuthService: locator.resolve(),
                      sdkManager: locator.resolve(),
                      completionManager: locator.resolve(),
                      analytics: locator.resolve(),
                      userService: locator.resolve(),
                      alertService: locator.resolve(),
                      bankManager: locator.resolve(),
                      versionСontrolManager: locator.resolve(),
                      partPayService: locator.resolve(),
                      timeManager: OptimizationCheсkerManager(),
                      enviromentManager: locator.resolve(),
                      remoteConfigService: locator.resolve(),
                      biometricAuthProvider: locator.resolve(),
                      payAmountValidationManager: locator.resolve(),
                      featureToggle: locator.resolve(),
                      authManager: locator.resolve(),
                      helperManager: locator.resolve(),
                      localSessionIdService: locator.resolve())
    }

    private func moduleView(presenter: AuthPresenter) -> ContentVC & IAuthVC {
        let view = AuthVC(presenter, analytics: locator.resolve())
        presenter.view = view
        return view
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
