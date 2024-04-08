//
//  ChallengeAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import UIKit

final class ChallengeAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor
    func createModule(transition: Transition,
                      completion: @escaping (SecureChallengeResolution) -> Void) {
        let router = moduleRouter()
        let presenter = modulePresenter(router, completion: completion)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        router.viewController = contentView
        transition.performTransition(for: contentView)
    }
    
    func moduleRouter() -> ChallengeRouter {
        ChallengeRouter(with: locator.resolve(), challangeRouteMap: locator.resolve())
    }

    private func modulePresenter(_ router: ChallengeRouter, completion: @escaping (SecureChallengeResolution) -> Void) -> ChallengePresenter {
        ChallengePresenter(router,
                           completionManager: locator.resolve(),
                           secureChallengeService: locator.resolve(),
                           bankAppManager: locator.resolve(),
                           analytics: locator.resolve(), 
                           completion: completion)
    }

    private func moduleView(presenter: ChallengePresenter) -> ContentVC & IChallengeVC {
        let view = ChallengeVC(presenter, analytics: locator.resolve())
        presenter.view = view
        return view
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
