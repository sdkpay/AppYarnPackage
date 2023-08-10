//
//  OtpAssembly.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import UIKit

final class OtpAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }
    
    func createModule() -> ContentVC {
        let presenter = modulePresenter()
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter() -> OtpPresenter {
        let presenter = OtpPresenter(otpService: locator.resolve(),
                                     userService: locator.resolve(),
                                     sdkManager: locator.resolve(),
                                     alertService: locator.resolve())
        return presenter
    }
    
    private func moduleView(presenter: OtpPresenter) -> ContentVC & IOtpVC {
        let view = OtpVC(presenter)
        presenter.view = view
        return view
    }
}
