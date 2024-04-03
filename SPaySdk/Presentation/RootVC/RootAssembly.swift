//
//  RootAssembly.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import Foundation

final class RootAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }
    
    func createModule() -> RootVC {
        let router = moduleRouter()
        let presenter = modulePresenter(router)
        let view = RootVC(presenter: presenter)
        router.viewController = view
        return view
    }
    
    private func modulePresenter(_ router: RootRouting) -> RootPresenter {
        let presenter = RootPresenter(router)
        return presenter
    }
    
    func moduleRouter() -> RootRouter {
        RootRouter(with: locator.resolve())
    }
}
