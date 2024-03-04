//
//  HintsModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import Foundation

final class HintsModuleAssembly {
    
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(mode: PaymentVCMode) -> ModuleVC {
        
        let presenter = modulePresenter(mode: mode)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func modulePresenter(mode: PaymentVCMode) -> HintsModulePresenting {
        
        switch mode {

        case .pay, .connect, .partPay :
            return HintsPaymentModulePresenter(userService: locator.resolve(), 
                                               payAmountValidationManager: locator.resolve())
        case .helper:
            return HintsHelperModulePresenter(helperConfigManager: locator.resolve(),
                                              payAmountValidationManager: locator.resolve())
        }
    }

    private func moduleView(presenter: HintsModulePresenting) -> ModuleVC & IHintsModuleVC {
        
        let view = HintsModuleVC(presenter)
        return view
    }
}

