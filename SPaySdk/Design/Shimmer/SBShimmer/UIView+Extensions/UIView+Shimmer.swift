//
//  UIView+Shimmer.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 21.03.2023.
//

import UIKit

extension UIView {
    func setShimmeringAnimation(_ animate: Bool, viewBackgroundColor: UIColor) {
        let currentShimmerLayer = layer.sublayers?.first(where: { $0.name == Key.shimmer })
        if animate {
            if currentShimmerLayer != nil { return }
        } else {
            currentShimmerLayer?.removeFromSuperlayer()
            return
        }

        // MARK: - Shimmering Layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = Key.shimmer
        gradientLayer.frame = frame
        gradientLayer.cornerRadius = min(bounds.height / 2, 5)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        let gradientColorOne = viewBackgroundColor.withAlphaComponent(0.3).cgColor
        let gradientColorTwo = viewBackgroundColor.withAlphaComponent(0.6).cgColor
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
        gradientLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)

        // MARK: - Shimmer Animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.2
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
}
