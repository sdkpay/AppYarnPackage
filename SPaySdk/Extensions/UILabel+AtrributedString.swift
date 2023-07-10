//
//  UILabel+AtrributedString.swift
//  SPaySdk
//
//  Created by Арсений on 08.07.2023.
//

import UIKit

extension UILabel {
    func setAttributedString(lineHeightMultiple: Double, kern: Double, string: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        self.attributedText = NSMutableAttributedString(string: string,
                                                                 attributes: [
                                                                    NSAttributedString.Key.kern: kern,
                                                                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                                                                 ])
    }
}
