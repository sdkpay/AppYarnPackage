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
