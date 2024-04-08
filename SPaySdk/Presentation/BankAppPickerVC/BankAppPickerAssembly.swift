//
//  BankAppPickerAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.10.2023.
//

import UIKit
import Combine

final class BankAppPickerAssembly {
    
    private let locator: LocatorService
    
    init(locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor 
    func createModule(transition: Transition, completion: @escaping Action) {
        
        let presenter = modulePresenter(completion: completion)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        
        transition.performTransition(for: contentView)
    }
    
    private func modulePresenter(completion: @escaping Action) -> BankAppPickerPresenter {
        let presenter = BankAppPickerPresenter(bankManager: locator.resolve(),
                                               authService: locator.resolve(),
                                               alertService: locator.resolve(), 
                                               analytics: locator.resolve(),
                                               completionManager: locator.resolve(),
                                               completion: completion)
        return presenter
    }
    
    private func moduleView(presenter: BankAppPickerPresenter) -> ContentVC & IBankAppPickerVC {
        let view = BankAppPickerVC(presenter, analytics: locator.resolve())
        presenter.view = view
        return view
    }
}
