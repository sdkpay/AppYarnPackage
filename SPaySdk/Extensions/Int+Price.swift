//
//  Int+Price.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.11.2022.
//

import Foundation

enum CurrencyCode: String {
    case RUB = "643"
    
    var symbol: String {
        switch self {
        case .RUB:
            return " ₽"
        }
    }
}

extension Int {
    
    func price(_ currency: String?) -> String {
        let currencyCode = CurrencyCode(rawValue: currency ?? "643") ?? .RUB
        return priceFormatted + currencyCode.symbol
    }

    func price(_ currency: CurrencyCode = .RUB) -> String {
        priceFormatted + currency.symbol
    }
    
    private var priceFormatted: String {
        
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        let finalPrice = Double(self) / 100
        
        var string = formatter.string(from: NSNumber(value: finalPrice)) ?? "0"
        
        if string.hasSuffix(",00") {
            string.removeLast(3)
        }
        
        return string
    }
}
