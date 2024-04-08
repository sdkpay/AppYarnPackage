//
//  CoverPushTransition.swift
//  Crypto
//
//  Created by Ипатов Александр Станиславович on 16.10.2023.
//

import UIKit

final class CoverPushTransition: Transition {

    private let targetNavigationController: ContentNC
    private let animationIsNeeded: Bool

    init(pushInto navigationController: ContentNC,
         animated: Bool = true) {
        targetNavigationController = navigationController
        animationIsNeeded = animated
    }
    
    @MainActor 
    func performTransition(for viewController: UIViewController) {
        
        guard let vc = viewController as? ContentVC else { return }
        
        targetNavigationController.pushViewController(vc,
                                                      animated: animationIsNeeded)
    }
}
