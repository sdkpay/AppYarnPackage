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
    
    func createModule() -> ContentVC {
        let router = moduleRouter()
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        router.viewController = contentView
        return contentView
    }
    
    func moduleRouter() -> ChallengeRouter {
        ChallengeRouter(with: locator)
    }

    private func modulePresenter(_ router: ChallengeRouter) -> ChallengePresenter {
        ChallengePresenter(router,
                           completionManager: locator.resolve(),
                           secureChallengeService: locator.resolve(),
                           analytics: locator.resolve())
    }

    private func moduleView(presenter: ChallengePresenter) -> ContentVC & IChallengeVC {
        let view = ChallengeVC(presenter)
        presenter.view = view
        return view
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
}
