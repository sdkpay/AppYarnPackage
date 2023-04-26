//
//  PartPayRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 26.04.2023.
//

import UIKit

protocol PartPayRouting {
    func presentWebView(with url: String, title: String)
}

final class PartPayRouter: PartPayRouting {
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    func presentWebView(with url: String, title: String) {
        let vc = WebViewAssembly(locator: locator).createModule(with: url, title: title)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
