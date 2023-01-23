//
//  CGFloat+Extension.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

extension CGFloat {
    func projectedOffset(decelerationRate: UIScrollView.DecelerationRate) -> CGFloat {
        let multiplier = 1 / (1 - decelerationRate.rawValue) / 1_000
        return self * multiplier
    }
}
