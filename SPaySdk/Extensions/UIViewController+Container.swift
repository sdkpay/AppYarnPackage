//
//  UIViewController+Container.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 17.11.2022.
//

import UIKit

extension UIViewController {
    func setupForContainer() {
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topRight, .topLeft],
                                cornerRadii: CGSize(width: CGFloat.containerCorner,
                                                    height: CGFloat.containerCorner))

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
}
