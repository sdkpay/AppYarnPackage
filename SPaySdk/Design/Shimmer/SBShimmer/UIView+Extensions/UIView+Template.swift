//
//  UIView+Template.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 21.03.2023.
//

import UIKit

enum Key {
    static let shimmer = "Key.ShimmerLayer"
    static let template = "Key.TemplateLayer"
}

extension UIView {
    func setTemplate(_ template: Bool) {
        var color: UIColor
        if #available(iOS 12, *), traitCollection.userInterfaceStyle == .dark {
            color = .darkShimmer
        } else {
            color = .lightShimmer
        }
        let currentTemplateLayer = layer.sublayers?.first(where: { $0.name == Key.template })

        if template {
            if currentTemplateLayer != nil { return }
        } else {
            currentTemplateLayer?.removeFromSuperlayer()
            layer.mask = nil
            return
        }

        let templateLayer = CALayer()
        templateLayer.name = Key.template
        setNeedsLayout()
        layoutIfNeeded()

        let templateFrame = frame
        let cornerRadius: CGFloat = max(layer.cornerRadius, min(bounds.height / 2, 5))

        // MARK: - Mask Layer
        let maskLayer = CAShapeLayer()
        let ovalPath = UIBezierPath(roundedRect: templateFrame, cornerRadius: cornerRadius)
        maskLayer.path = ovalPath.cgPath
        layer.mask = maskLayer

        // MARK: Template Layer
        templateLayer.frame = templateFrame
        templateLayer.cornerRadius = cornerRadius
        templateLayer.backgroundColor = color.cgColor
        layer.addSublayer(templateLayer)
        templateLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude - 1.0)
    }
}
