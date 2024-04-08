//
//  UILabel+Spacing.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.09.2023.
//

import UIKit

extension UILabel {

    func letterSpacing(_ spacing: CGFloat) {
        let attributedStr = NSMutableAttributedString(string: self.text ?? "")
        attributedStr.addAttributes([.kern: spacing], range: NSRange(location: 0, length: attributedStr.length))
        self.attributedText = attributedStr
    }
}
