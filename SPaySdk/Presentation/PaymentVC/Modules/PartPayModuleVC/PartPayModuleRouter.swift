//
//  PartPayModuleRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.03.2024.
//

import UIKit

protocol PartPayModuleRouting: UrlOpenable {
    
    func presentWebView(with url: String)
    
    var viewController: ModuleVC? { get set }
}

final class PartPayModuleRouter: PartPayModuleRouting {
    
    weak var viewController: ModuleVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }

    @MainActor
    func presentWebView(with url: String) {
        let vc = WebViewAssembly(locator: locator).createModule(with: url)
        viewController?.contentParrent?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
