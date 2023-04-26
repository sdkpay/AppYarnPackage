//
//  WebViewAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

final class WebViewAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }
    
    func createModule(with url: String) -> ContentVC {
        let presenter = modulePresenter(with: url)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }
    
    private func modulePresenter(with url: String) -> WebViewPresenter {
        WebViewPresenter(with: url)
    }

    private func moduleView(presenter: WebViewPresenter) -> ContentVC & IWebViewVC {
        let view = WebViewVC(presenter)
        presenter.view = view
        return view
    }
}
