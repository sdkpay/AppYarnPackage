//
//  SBSuperviewGuide.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public enum SBSuperviewGuide {
    case none
    case layoutMargins
    case readableContent
    case safeAreaLayout
    
    func convertedToESLGuide(superview: UIView) -> SBGuide? {
        switch self {
        case .none:
            return nil
        case .layoutMargins:
            return .layoutMargins(of: superview)
        case .readableContent:
            return .readableContent(of: superview)
        case .safeAreaLayout:
            return .safeAreaLayout(of: superview)
        }
    }
}
