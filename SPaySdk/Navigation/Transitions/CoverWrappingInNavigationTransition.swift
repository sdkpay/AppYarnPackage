//
//  CoverWrappingInNavigationTransition.swift
//  Crypto
//
//  Created by Ипатов Александр Станиславович on 16.10.2023.
//

import UIKit

final class CoverWrappingInNavigationTransition: Transition {
    
    private weak var baseViewController: UIViewController?
    private var animated: Bool
    
    init(on viewController: UIViewController, animated: Bool) {
        self.baseViewController = viewController
        self.animated = animated
    }

    func performTransition(for viewController: UIViewController) {
        
        guard let vc = viewController as? ContentVC else { return }
        
        let navigationController = ContentNC(rootViewController: vc)
        baseViewController?.present(navigationController, animated: animated)
    }
}
