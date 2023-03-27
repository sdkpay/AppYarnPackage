//
//  Date+Extension.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 10.03.2023.
//

import Foundation

extension Date {
    var rfcFormatted: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        return dateFormatter.string(from: self)
    }
}
