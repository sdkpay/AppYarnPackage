//
//  UIView+Blur.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.12.2023.
//

import UIKit

extension UIView {
    
    func applyBlurEffect(style: UIBlurEffect.Style = .regular, alphaValue: CGFloat = 1.0) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = alphaValue
        blurEffectView.bounds = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}
