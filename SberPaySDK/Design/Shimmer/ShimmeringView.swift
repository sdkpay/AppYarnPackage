//
//  ShimmeringView.swift
//  SberPaySDK
//
//  Created by Ипатов Александр Станиславович on 20.03.2023.
//

import UIKit

protocol ShimmeringView where Self: UIView {
    var shimmeringItems: [UIView] { get }
    var excludedItems: Set<UIView> { get }
}

extension ShimmeringView {
    var shimmeringItems: [UIView] { [self] }
    var excludedItems: Set<UIView> { [self] }
}
