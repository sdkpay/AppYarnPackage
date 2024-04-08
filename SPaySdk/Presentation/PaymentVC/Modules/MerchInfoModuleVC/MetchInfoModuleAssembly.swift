//
//  MetchInfoModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

final class MetchInfoModuleAssembly {
    
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
    
    func modulePresenter(_ router: PaymentRouting) -> MerchInfoModulePresenting {
        MerchInfoModulePresenter(router, userService: locator.resolve())
    }

    private func moduleView(presenter: MerchInfoModulePresenting) -> ModuleVC & IMerchInfoModuleVC {
        
        let view = MerchInfoModuleVC(presenter)
        return view
    }
}
