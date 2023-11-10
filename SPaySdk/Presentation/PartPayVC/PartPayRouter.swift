//
//  PartPayRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 26.04.2023.
//

import UIKit

protocol PartPayRouting {
    func presentWebView(with url: String)
}

final class PartPayRouter: PartPayRouting {
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    @MainActor
    func presentWebView(with url: String) {
        let vc = WebViewAssembly(locator: locator).createModule(with: url)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
