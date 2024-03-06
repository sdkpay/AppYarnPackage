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

    func createModule(partPaySelected: @escaping Action) -> ContentVC {
        let router = moduleRouter()
        let presenter = modulePresenter(router, partPaySelected: partPaySelected)
        let contentView = moduleView(presenter: presenter, analyticsService: locator.resolve())
        presenter.view = contentView
        router.viewController = contentView
        return contentView
    }
    
    func moduleRouter() -> PartPayRouter {
        PartPayRouter(with: locator)
    }

    private func modulePresenter(_ router: PartPayRouter,
                                 partPaySelected: @escaping Action) -> PartPayPresenter {
        let presenter = PartPayPresenter(router,
                                         partPayService: locator.resolve(), 
                                         partPayModule: partPayModule(),
                                         timeManager: OptimizationCheсkerManager(),
                                         analytics: locator.resolve(),
                                         partPaySelected: partPaySelected)
        return presenter
    }
    
    private func moduleView(presenter: PartPayPresenter,
                            analyticsService: AnalyticsService) -> ContentVC & IPartPayVC {
        let view = PartPayVC(presenter, analyticsService: analyticsService)
        presenter.view = view
        return view
    }
    
    private func partPayModule() -> ModuleVC {
        PartPayModuleAssembly(locator: locator).createModule()
    }
}
