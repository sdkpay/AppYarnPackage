//
//  CGPoint+Extension.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

extension CGPoint {
    func projectedOffset(decelerationRate: UIScrollView.DecelerationRate) -> CGPoint {
        CGPoint(x: x.projectedOffset(decelerationRate: decelerationRate),
                y: y.projectedOffset(decelerationRate: decelerationRate))
    }

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x,
                y: left.y + right.y)
    }
}
