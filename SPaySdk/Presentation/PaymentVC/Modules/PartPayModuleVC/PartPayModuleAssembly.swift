//
//  PartPayModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 03.03.2024.
//

import UIKit

final class PartPayModuleAssembly {
    
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(router: PaymentRouting) -> ModuleVC {
        
        var presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting) -> PartPayModulePresenting {
       PartPayModulePresenter(router,
                              partPayService: locator.resolve(),
                              analytics: locator.resolve(),
                              userService: locator.resolve())
    }

    private func moduleView(presenter: PartPayModulePresenting) -> ModuleVC & IPartPayModuleVC {
        
        let view = PartPayModuleVC(presenter)
        return view
    }
}
