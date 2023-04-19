//
//  UIEdgeInsets+Extension.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

extension UIEdgeInsets {
    /// Creates equal insets for all 4 edges.
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}
