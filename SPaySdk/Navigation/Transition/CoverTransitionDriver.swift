//
//  CoverTransitionDriver.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

final class CoverTransitionDriver: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    override var wantsInteractiveStart: Bool {
        get {
            panRecognizer.state == .began
        }
        set {
            super.wantsInteractiveStart = newValue
        }
    }

    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDismiss)
        )
        panRecognizer.delegate = self
        return panRecognizer
    }()

    private weak var presentedController: UIViewController?

    init(controller: UIViewController) {
        super.init()
        
        controller.view.addGestureRecognizer(panRecognizer)
        presentedController = controller
    }

    private var maxTranslation: CGFloat? {
        let height = presentedController?.view.frame.height ?? 0
        return height > 0 ? height : nil
    }

    @objc
    private func handleDismiss(_ sender: UIPanGestureRecognizer) {
        guard let maxTranslation = maxTranslation else { return }

        switch sender.state {
        case .began:
            let isRunning = percentComplete != 0
            if !isRunning {
                presentedController?.dismiss(animated: true)
            }
            pause()
        case .changed:
            let increment = sender.incrementToBottom(maxTranslation: maxTranslation)
            update(percentComplete + increment)
        case .ended, .cancelled:
            if sender.isProjectedToDownHalf(
                maxTranslation: maxTranslation,
                percentComplete: percentComplete
            ) {
                finish()
                NotificationCenter.default.post(name: Notification.Name(closeSDKNotification),
                                                object: nil,
                                                userInfo: nil)
            } else {
                cancel()
            }

        case .failed:
            cancel()
        default:
            break
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = panRecognizer.velocity(in: nil)
        return velocity.y > 0 && abs(velocity.y) > abs(velocity.x)
    }
}
