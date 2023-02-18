//
//  Collection+Extension.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 17.02.2023.
//

import Foundation

extension Collection {
    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return "json serialization error: \(error)"
        }
    }
}
