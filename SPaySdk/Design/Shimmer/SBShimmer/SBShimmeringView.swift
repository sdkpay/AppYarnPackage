//
//  SBShimmeringView.swift
//  UIView-Shimmer
//
//  Created by Ömer Faruk Öztürk on 15.01.2021.
//

import UIKit

extension UIColor {
    static let lightShimmer = UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1.0)
    static let darkShimmer = UIColor(red: 48 / 255, green: 48 / 255, blue: 48 / 255, alpha: 1.0)
}

public protocol SBShimmeringView where Self: UIView {
    var shimmeringAnimatedItems: [UIView] { get }
    var excludedItems: Set<UIView> { get }
}

extension SBShimmeringView {
    public var shimmeringAnimatedItems: [UIView] { [self] }
    public var excludedItems: Set<UIView> { [] }
}
