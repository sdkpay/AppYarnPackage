//
//  PartPayAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import Foundation

final class PartPayAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    @MainActor
    func createModule(transition: Transition, partPaySelected: @escaping Action) {
        let router = moduleRouter()
        let presenter = modulePresenter(router, partPaySelected: partPaySelected)
        let contentView = moduleView(presenter: presenter, analyticsService: locator.resolve())
        presenter.view = contentView
        router.viewController = contentView
        transition.performTransition(for: contentView)
    }
    
    func moduleRouter() -> PartPayRouter {
        PartPayRouter(with: locator.resolve())
    }

    private func modulePresenter(_ router: PartPayRouter,
                                 partPaySelected: @escaping Action) -> PartPayPresenter {
        let presenter = PartPayPresenter(router,
                                         partPayService: locator.resolve(), 
                                         partPayModule: partPayModule(),
                                         analytics: locator.resolve(),
                                         partPaySelected: partPaySelected)
        return presenter
    }
    
    private func moduleView(presenter: PartPayPresenter,
                            analyticsService: AnalyticsService) -> ContentVC & IPartPayVC {
        let view = PartPayVC(presenter, analytics: locator.resolve())
        presenter.view = view
        return view
    }
    
    private func partPayModule() -> ModuleVC {
        PartPayModuleAssembly(locator: locator).createModule()
    }
}
