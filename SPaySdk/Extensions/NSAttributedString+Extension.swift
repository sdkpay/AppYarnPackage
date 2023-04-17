//
//  NSAttributedString+Extension.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import Foundation

extension NSAttributedString {
    convenience init(text: String, dedicatedPart: String, attrebutes: [NSAttributedString.Key: Any]) {
        let str = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: dedicatedPart)
        str.addAttributes(attrebutes, range: range)
        self.init(attributedString: str)
    }
}
