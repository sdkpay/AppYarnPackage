//
//  ShakableView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

protocol Shakable where Self: UIView {
    func shake()
}

extension Shakable {
    func shake() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 10, y: center.y))
        layer.add(animation, forKey: "position")
    }
}
