//
//  CoverTransitioningDelegate.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

final class CoverTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private var driver: CoverTransitionDriver?

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        driver = CoverTransitionDriver(controller: presented)

        return CoverPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source
        )
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        CoverPresentAnimatedTransitioning()
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        CoverDismissAnimatedTransitioning()
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        driver
    }
}
