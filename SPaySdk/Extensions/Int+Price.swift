//
//  Int+Price.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.11.2022.
//

import Foundation

enum CurrencyCode: Int {
    case RUB = 643
    
    var symbol: String {
        switch self {
        case .RUB:
            return " ₽"
        }
    }
}

extension Int {
    func price(_ currency: CurrencyCode = .RUB) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let finalPrice = Double(self) / 100
        let priceString = formatter.string(from: NSNumber(value: finalPrice)) ?? "0"
        let currencyString = currency.symbol
        return priceString + currencyString
    }
}
