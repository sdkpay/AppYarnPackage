//
//  UIView+Horisontal+Vertical.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

extension UIView {
    
    func touchHorizontalEdgesToSuperview(withInset inset: CGFloat = .zero) {
        touchEdgesToSuperview(ofGroup: .horizontal, withInset: inset)
    }
    
    func touchVerticalEdgesToSuperview(withInset inset: CGFloat = .zero) {
        touchEdgesToSuperview(ofGroup: .vertical, withInset: inset)
    }
}
