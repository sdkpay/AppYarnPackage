//
//  SBOffset.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import Foundation

typealias SBDimensionalInsets = CGSize

public struct SBOffset {
    
    public let x: CGFloat
    public let y: CGFloat
    
    public static let zero = SBOffset(x: 0, y: 0)
    
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}
