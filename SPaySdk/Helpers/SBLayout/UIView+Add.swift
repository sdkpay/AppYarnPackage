//
//  UIView+Add.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public extension UIView {
    @discardableResult
    func add(toSuperview superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }
}
