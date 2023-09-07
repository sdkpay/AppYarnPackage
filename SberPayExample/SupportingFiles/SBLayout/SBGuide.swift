//
//  SBGuide.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

typealias SBSizeInsets = UIOffset

enum SBGuide {
    case custom(UILayoutGuide)
    case layoutMargins(of: UIView)
    case readableContent(of: UIView)
    case safeAreaLayout(of: UIView)
    
    var layoutGuide: UILayoutGuide {
        switch self {
        case .custom(let layoutGuide):
            return layoutGuide
        case .layoutMargins(let view):
            return view.layoutMarginsGuide
        case .readableContent(let view):
            return view.readableContentGuide
        case .safeAreaLayout(let view):
            return view.safeAreaLayoutGuide
        }
    }
}
