//
//  Data+Extension.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 17.02.2023.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
    
    func securePrintedJSONString(keys: [String]) -> NSString? {
        guard let startDictionary = try? JSONSerialization.jsonObject(with: self,
                                                                      options: [.mutableContainers]) as? [String: String?]
        else { return nil }

        var endDictionary: [String: String?] = [:]

        for item in startDictionary {
            if keys.contains(item.key) {
                endDictionary[item.key] = item.value?.masked()
            } else {
                endDictionary[item.key] = item.value
            }
        }
        return endDictionary.json as NSString
    }
}

extension Encodable {
    var data: Data? {
        try? JSONEncoder().encode(self)
    }
}

extension Data {
    func decode<T: Codable> (to type: T.Type) -> T? {
        try? JSONDecoder().decode(T.self, from: self)
    }
}

extension StringProtocol {
    func masked(with char: Character = "#") -> String {
        String(repeating: char, count: Swift.max(0, count))
    }
}
