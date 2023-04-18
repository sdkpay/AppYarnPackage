//
//  BaseView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 17.04.2023.
//

import UIKit

private extension CGFloat {
    static let corner = 8.0
}

extension UIView {
    func setupForBase() {
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = .corner
    }
}
