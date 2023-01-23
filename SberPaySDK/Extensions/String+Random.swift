//
//  String+Random.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 29.11.2022.
//

import Foundation

extension String {
    static func generateRandom(with length: Int) -> String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(length))
    }
}
