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

    func createModule(with state: PaymentVCMode, router: PaymentRouting) -> UIViewController & IPurchaseModuleVC {
        
        let presenter = modulePresenter(router, with: state)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting,
                         with state: PaymentVCMode) -> PurchaseModulePresenting {
        
        switch state {
            
        case .pay:
           return PayPurchaseModulePresenter(router,
                                             manager: locator.resolve(),
                                             userService: locator.resolve(),
                                             partPayService: locator.resolve(),
                                             payAmountValidationManager: locator.resolve())
        case .helper:
            return 
    }

    private func moduleView(presenter: PurchaseModulePresenting) -> UIViewController & IPaymentModuleVC {
        
        let view = PaymentModuleVC(presenter)
        presenter.view = view
        return view
    }
}

