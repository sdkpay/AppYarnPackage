//
//  PurchaseModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

final class PurchaseModuleAssembly {
    
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(router: PaymentRouting) -> ModuleVC {
        
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting) -> PurchaseModulePresenting {
        PurchaseModulePresenter(router,
                                manager: locator.resolve(),
                                userService: locator.resolve(),
                                partPayService: locator.resolve(),
                                payAmountValidationManager: locator.resolve())
    }

    private func moduleView(presenter: PurchaseModulePresenting) -> ModuleVC & IPurchaseModuleVC {
        
        let view = PurchaseModuleVC(presenter)
        return view
    }
}
