//
//  LogAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit

final class LogAssembly {
    func createModule() -> UIViewController {
        let presenter = modulePresenter()
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return UINavigationController(rootViewController: contentView)
    }

    private func modulePresenter() -> LogPresenter {
        let presenter = LogPresenter()
        return presenter
    }
    
    private func moduleView(presenter: LogPresenter) -> (UIViewController & ILogVC) {
        let view = LogVC(presenter)
        presenter.view = view
        return view
    }
}
