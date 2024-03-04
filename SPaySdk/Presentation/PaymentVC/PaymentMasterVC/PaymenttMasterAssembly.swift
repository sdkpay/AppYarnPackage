//
//  PaymenttMasterAssembly.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class PaymentMasterAssembly {
    
    private let locator: LocatorService
    
    private var paymentVCMode: PaymentVCMode = .pay

    init(locator: LocatorService) {
        self.locator = locator
    }
    
    private var paymentsModuls: [PaymentModule] {
        
        switch paymentVCMode {
            
        case .pay:
            return [
                .merchInfoModule,
                .purchaseModule,
                .hintModule,
                .paymentFeatureModule,
                .paymentModule
            ]
        case .helper:
            return [
                .merchInfoModule,
                .purchaseModule,
                .hintModule,
                .helperFeatureModule
            ]
        case .connect:
            return [
                .merchInfoModule,
                .connectInfoModule,
                .hintModule,
                .paymentFeatureModule,
                .paymentModule
            ]
        case .partPay:
            return [
                .partPayModule,
                .paymentFeatureModule,
                .paymentModule
            ]
        }
    }

    func createModule(with state: PaymentVCMode) -> ContentVC {
        paymentVCMode = state
        let router = moduleRouter()
        let presenter = modulePresenter(router)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        router.viewController = contentView
        return contentView
    }
    
    func modulePresenter(_ router: PaymentRouting) -> PaymentMasterPresenter {
        
        var moduls = [ModuleVC]()
        
        paymentsModuls.forEach { module in
            moduls.append(assemblyModule(module, router: router))
        }
        
        let presenter = PaymentMasterPresenter(analytics: locator.resolve(),
                                               submodule: moduls,
                                               mode: paymentVCMode,
                                               helperConfig: locator.resolve(),
                                               partPayService: locator.resolve(),
                                               completionManager: locator.resolve())
        
        return presenter
    }

    func moduleRouter() -> PaymentRouter {
        PaymentRouter(with: locator)
    }

    private func moduleView(presenter: PaymentMasterPresenter) -> ContentVC & IPaymentMasterVC {
        let view = PaymentMasterVC(presenter)
        presenter.view = view
        return view
    }
    
    private func assemblyModule(_ module: PaymentModule, router: PaymentRouting) -> ModuleVC {
        
        switch module {
            
        case .merchInfoModule:
            
            return MetchInfoModuleAssembly(locator: locator).createModule(router: router)
        case .purchaseModule:
            
            return PurchaseModuleAssembly(locator: locator).createModule(router: router)
        case .connectInfoModule:
            
            return ConnectInfoModuleAssembly(locator: locator).createModule()
        case .helperFeatureModule:
            
            return HelperFeatureModuleAssembly(locator: locator).createModule(router: router)
        case .paymentFeatureModule:
            
            return PaymentFeatureModuleAssembly(locator: locator).createModule(router: router)
        case .paymentModule:
            
            return PaymentModuleAssembly(locator: locator).createModule(with: paymentVCMode, router: router)
        case .partPayModule:
            
            return PartPayModuleAssembly(locator: locator).createModule(router: router)
        case .hintModule:
            
            return HintsModuleAssembly(locator: locator).createModule(mode: paymentVCMode)
        }
    }
}
