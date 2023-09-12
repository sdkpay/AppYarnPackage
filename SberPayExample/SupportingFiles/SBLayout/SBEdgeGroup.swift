//
//  SBEdgeGroup.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import Foundation

enum SBEdgeGroup {
    case horizontal
    case vertical
    
    var edges: [SBEdge] {
        switch self {
        case .horizontal:
            return [.left, .right]
        case .vertical:
            return [.top, .bottom]
        }
    }
}
