//
//  ConnectInfoModuleAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

final class ConnectInfoModuleAssembly {
    
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule() -> ModuleVC {
        
        let presenter = modulePresenter()
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    func modulePresenter() -> ConnectInfoModulePresenting {
        ConnectInfoModulePresenter()
    }

    private func moduleView(presenter: ConnectInfoModulePresenting) -> ModuleVC & IConnectInfoModuleVC {
        
        let view = ConnectInfoModuleVC(presenter)
        return view
    }
}
