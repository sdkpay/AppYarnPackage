//
//  Style.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 12.12.2022.
//

import UIKit

// Common
extension CGFloat {
    static let containerCorner = 20.0
    static let margin = 16.0
    static let marginHalf = 8.0
    static let defaultButtonCorner = 20.0
    static let defaultButtonHeight = 60.0
    static let defaultButtonWidth = UIScreen.main.bounds.width - (2 * .margin)
    static let minScreenSize = 375.0
    static let vcMaxHeight = UIScreen.main.bounds.height * 0.8
}

extension TimeInterval {
    static let presentTransitionDuration: TimeInterval = 0.4
}
