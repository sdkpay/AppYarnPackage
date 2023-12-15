//
//  AlertAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.05.2023.
//

import UIKit

final class AlertAssembly {
    
    func createModule(alertModel: AlertViewModel,
                      liveCircleManager: LiveCircleManager,
                      alertResultAction: @escaping AlertResultAction) -> ContentVC {
        let presenter = modulePresenter(alertModel: alertModel,
                                        liveCircleManager: liveCircleManager,
                                        alertResultAction: alertResultAction)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(alertModel: AlertViewModel,
                                 liveCircleManager: LiveCircleManager,
                                 alertResultAction: @escaping AlertResultAction) -> AlertPresenter {
        let presenter = AlertPresenter(with: alertModel, liveCircleManager: liveCircleManager, alertResultAction: alertResultAction)
        return presenter
    }
    
    private func moduleView(presenter: AlertPresenter) -> ContentVC & IAlertVC {
        let view = AlertVC(presenter)
        presenter.view = view
        return view
    }
}
