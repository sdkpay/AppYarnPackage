//
//  SBOffset.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import Foundation

typealias SBDimensionalInsets = CGSize

struct SBOffset {
    
    let x: CGFloat
    let y: CGFloat
    
    static let zero = SBOffset(x: 0, y: 0)
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}
