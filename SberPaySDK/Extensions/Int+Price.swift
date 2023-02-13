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
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let finalPrice = Double(self) / 100
        return (formatter.string(from: NSNumber(value: finalPrice)) ?? "0") + " ₽"
    }
}
