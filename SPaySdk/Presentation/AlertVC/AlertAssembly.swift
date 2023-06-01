//
//  AlertAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.05.2023.
//

import UIKit

final class AlertAssembly {
    func createModule(alertModel: AlertViewModel) -> ContentVC {
        let presenter = modulePresenter(alertModel: alertModel)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(alertModel: AlertViewModel) -> AlertPresenter {
        let presenter = AlertPresenter(with: alertModel)
        return presenter
    }
    
    private func moduleView(presenter: AlertPresenter) -> ContentVC & IAlertVC {
        let view = AlertVC(presenter)
        presenter.view = view
        return view
    }
}
