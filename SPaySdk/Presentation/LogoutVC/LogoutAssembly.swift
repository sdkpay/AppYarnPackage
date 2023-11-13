//
//  LogoutAssembly.swift
//  SPaySdk
//
//  Created by Арсений on 18.08.2023.
//

import UIKit

final class LogoutAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }
    
    func createModule(with userInfo: UserInfo) -> ContentVC {
        let presenter = modulePresenter()
        let contentView = moduleView(presenter: presenter, with: userInfo)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter() -> LogoutPresenter {
        LogoutPresenter(sdkManager: locator.resolve(),
                        storage: locator.resolve(),
                        userService: locator.resolve(),
                        authManager: locator.resolve(),
                        analytics: locator.resolve(),
                        completionManager: locator.resolve())
    }

    private func moduleView(presenter: LogoutPresenter, with userInfo: UserInfo) -> ContentVC & ILogoutVC {
        let view = LogoutVC(presenter, with: userInfo)
        presenter.view = view
        return view
    }
}
