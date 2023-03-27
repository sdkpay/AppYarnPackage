//
//  UIView+Extensions.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 21.03.2023.
//

import UIKit

extension UIView {
    var allTemplateViews: [UIView] {
        var views = [UIView]()
        getSubShimmerViews(&views)
        return views
    }
    
    var frame: CGRect {
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
            return CGRect(x: horizontalX,
                          y: 0,
                          width: width,
                          height: intrinsicContentSize.height)
        }

        return bounds
    }

    private func getSubShimmerViews(_ views: inout [UIView], excludedViews: Set<UIView> = []) {
        var excludedViews = excludedViews
        if let view = self as? SBShimmeringView {
            excludedViews = excludedViews.union(view.excludedItems)
            views.append(contentsOf: view.shimmeringAnimatedItems.filter({ !excludedViews.contains($0) }))
        }
        subviews.forEach { $0.getSubShimmerViews(&views, excludedViews: excludedViews) }
    }
}

extension UIView {
    func shimmer(_ value: Bool = true,
                 animate: Bool = true,
                 viewBackgroundColor: UIColor = .backgroundSecondary) {
        allTemplateViews.forEach {
            $0.setTemplate(value)
            if animate {
                $0.setShimmeringAnimation(value, viewBackgroundColor: viewBackgroundColor)
            }
        }
    }
}
