//
//  SBEdge.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

enum SBEdge {
    case top
    case bottom
    case left
    case right
    
    static let all: [SBEdge] = [.top, .bottom, .left, .right]
    
    var directionalMultiplier: CGFloat {
        switch self {
        case .left, .top:
            return 1.0
        case .right, .bottom:
            return -1.0
        }
    }
    
    var convertedToNSLayoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}
