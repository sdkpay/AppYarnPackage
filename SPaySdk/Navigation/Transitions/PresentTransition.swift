//
//  PresentTransition.swift
//  Crypto
//
//  Created by Ипатов Александр Станиславович on 15.03.2024.
//

import UIKit

final class PresentTransition: Transition {
    
    private let targetController: UIViewController
    private let animationIsNeeded: Bool

    init(pushInto targetController: UIViewController,
         animated: Bool = true
    ) {
        self.targetController = targetController
        animationIsNeeded = animated
    }
    func performTransition(for viewController: UIViewController) {
        targetController.present(viewController, animated: animationIsNeeded)
    }
}
