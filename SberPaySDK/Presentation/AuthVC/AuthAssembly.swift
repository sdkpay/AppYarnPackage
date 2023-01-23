//
//  AuthAssembly.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class AuthAssembly {
    func createModule(manager: SDKManager, analytics: AnalyticsService) -> ContentVC {
        let presenter = modulePresenter(manager, analytics: analytics)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(_ manager: SDKManager, analytics: AnalyticsService) -> AuthPresenter {
        let presenter = AuthPresenter(manager: manager, analytics: analytics)
        return presenter
    }
    
    private func moduleView(presenter: AuthPresenter) -> ContentVC & IAuthVC {
        let view = AuthVC(presenter)
        presenter.view = view
        return view
    }
}
