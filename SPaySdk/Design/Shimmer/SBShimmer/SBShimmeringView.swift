//
//  SBShimmeringView.swift
//  UIView-Shimmer
//
//  Created by Ömer Faruk Öztürk on 15.01.2021.
//

import UIKit

extension UIColor {
    static let lightShimmer = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1.0)
    static let darkShimmer = UIColor(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1.0)
}

public protocol SBShimmeringView where Self: UIView {
    var shimmeringAnimatedItems: [UIView] { get }
    var excludedItems: Set<UIView> { get }
}

extension SBShimmeringView {
    public var shimmeringAnimatedItems: [UIView] { [self] }
    public var excludedItems: Set<UIView> { [] }
}
