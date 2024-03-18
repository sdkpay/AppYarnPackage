//
//  BankAppPickerAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.10.2023.
//

import UIKit

final class BankAppPickerAssembly {
    private let locator: LocatorService
    
    init(locator: LocatorService) {
        self.locator = locator
    }
    
    func createModule(completion: @escaping Action) -> ContentVC {
        let presenter = modulePresenter(completion: completion)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
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
        let view = BankAppPickerVC(presenter)
        presenter.view = view
        return view
    }
}
