//
//  OtpAssembly.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import UIKit

final class OtpAssembly {
    func createModule() -> ContentVC {
        let presenter = modulePresenter()
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter() -> OtpPresenter {
        let presenter = OtpPresenter()
        return presenter
    }
    
    private func moduleView(presenter: OtpPresenter) -> ContentVC & IOtpVC {
        let view = OtpVC(presenter)
        presenter.view = view
        return view
    }
}
