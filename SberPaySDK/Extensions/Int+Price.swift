//
//  Int+Price.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.11.2022.
//

import Foundation

extension Int {
    var price: String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        return (formatter.string(from: NSNumber(value: self)) ?? "0") + " ₽"
    }
}
