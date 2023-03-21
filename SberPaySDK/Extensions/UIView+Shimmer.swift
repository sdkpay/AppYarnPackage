//
//  UIView+Shimmer.swift
//  SberPaySDK
//
//  Created by Ипатов Александр Станиславович on 20.03.2023.
//
import UIKit

extension UIImageView: ShimmeringView {}

private enum Constants {
    static let shimmer = "Key.ShimmerLayer"
    static let template = "Key.TemplateLayer"
}

extension UIView {
    var allTemplateViews: [UIView] {
        var views = [UIView]()
        getSubShimmerViews(&views)
        return views
    }
    
    func shimmering(_ value: Bool = true,
                    animate: Bool = true,
                    viewBackgroundColor: UIColor = .main) {
        allTemplateViews.forEach {
            $0.setTemplate(value)
            if animate {
                $0.setShimmeringAnimation(value, viewBackgroundColor: viewBackgroundColor)
            }
        }
    }

    private func getSubShimmerViews(_ views: inout [UIView],
                                    excludedViews: Set<UIView> = []) {
        var excludedViews = excludedViews
        if let view = self as? ShimmeringView {
            excludedViews = excludedViews.union(view.excludedItems)
            views.append(contentsOf: view.shimmeringItems.filter({ !excludedViews.contains($0) }))
        }
        subviews.forEach { $0.getSubShimmerViews(&views, excludedViews: excludedViews) }
    }

    func getFrame() -> CGRect {
        if let label = self as? UILabel {
            let width: CGFloat = intrinsicContentSize.width
            var horizontalX: CGFloat!
            switch label.textAlignment {
            case .center:
                horizontalX = bounds.midX - width / 2
            case .right:
                horizontalX = bounds.width - width
            default:
                horizontalX = 0
            }
            return CGRect(x: horizontalX, y: 0, width: width, height: intrinsicContentSize.height)
        }
        print(bounds)
        return bounds
    }

    func setTemplate(_ template: Bool) {
        let currentTemplateLayer = layer.sublayers?.first(where: { $0.name == Constants.template })

        if template {
            if currentTemplateLayer != nil { return }
        } else {
            currentTemplateLayer?.removeFromSuperlayer()
            layer.mask = nil
            return
        }

        let templateLayer = CALayer()
        templateLayer.name = Constants.template

        setNeedsLayout()
        layoutIfNeeded()

        let templateFrame = getFrame()
        let cornerRadius: CGFloat = max(layer.cornerRadius, min(bounds.height / 2, 5))

        // MARK: - Mask Layer
        let maskLayer = CAShapeLayer()
        let ovalPath = UIBezierPath(roundedRect: templateFrame, cornerRadius: cornerRadius)
        maskLayer.path = ovalPath.cgPath
        layer.mask = maskLayer

        // MARK: Template Layer
        templateLayer.frame = templateFrame
        templateLayer.cornerRadius = cornerRadius
        templateLayer.backgroundColor = UIColor.textSecondary.cgColor
        layer.addSublayer(templateLayer)
        templateLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude - 1.0)
    }
}

extension UIView {
    func setShimmeringAnimation(_ animate: Bool, viewBackgroundColor: UIColor) {
        let currentShimmerLayer = layer.sublayers?.first(where: { $0.name == Constants.shimmer })
        if animate {
            if currentShimmerLayer != nil { return }
        } else {
            currentShimmerLayer?.removeFromSuperlayer()
            return
        }

        // MARK: - Shimmering Layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = Constants.shimmer
        gradientLayer.frame = getFrame()
        gradientLayer.cornerRadius = min(bounds.height / 2, 5)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        let gradientColorOne = viewBackgroundColor.withAlphaComponent(0.5).cgColor
        let gradientColorTwo = viewBackgroundColor.withAlphaComponent(0.8).cgColor
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
        gradientLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)

        // MARK: - Shimmer Animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.25
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
}
