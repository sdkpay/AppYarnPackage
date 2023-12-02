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
    
    func createModule(completion: @escaping Action) -> ContentVC {
        let presenter = modulePresenter(completion: completion)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(completion: @escaping Action) -> OtpPresenter {
        let presenter = OtpPresenter(otpService: locator.resolve(),
                                     userService: locator.resolve(),
                                     authManager: locator.resolve(),
                                     sdkManager: locator.resolve(),
                                     alertService: locator.resolve(),
                                     analytics: locator.resolve(),
                                     completionManager: locator.resolve(),
                                     parsingErrorAnaliticManager: locator.resolve(),
                                     completion: completion)
        return presenter
    }
    
    private func moduleView(presenter: OtpPresenter) -> ContentVC & IOtpVC {
        let view = OtpVC(presenter)
        presenter.view = view
        return view
    }
}
