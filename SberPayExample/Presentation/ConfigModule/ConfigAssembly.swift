//
//  ConfigAssembly.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import Foundation

final class ConfigAssembly {
    
    func createModule() -> ConfigVC {
        let presenter = modulePresenter()
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    private func modulePresenter() -> ConfigPresenter {
        ConfigPresenter()
    }
    
    private func moduleView(presenter: ConfigPresenterProtocol) -> ConfigVC {
        ConfigVC(presenter: presenter)
    }
}
