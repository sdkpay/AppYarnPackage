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
    
    @MainActor
    func createModule(transition: Transition, with url: String) {
        let presenter = modulePresenter(with: url)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        transition.performTransition(for: contentView)
    }
    
    private func modulePresenter(with url: String) -> WebViewPresenter {
        WebViewPresenter(with: url, analytics: locator.resolve())
    }

    private func moduleView(presenter: WebViewPresenter) -> ContentVC & IWebViewVC {
        let view = WebViewVC(presenter, analytics: locator.resolve())
        presenter.view = view
        return view
    }
}
