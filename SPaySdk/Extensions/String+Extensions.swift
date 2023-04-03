//
//  String+Extensions.swift.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import Foundation

extension String {
    var card: String {
        "•• \(self)"
    }
    
    static let bankApp = UserDefaults.bankApp
    static let localization = UserDefaults.localization
    static let schemas = UserDefaults.schemas
    static let images = UserDefaults.images
    static let dynatraceUrl = UserDefaults.bankApp
    static let dynatraceId = UserDefaults.bankApp
}
