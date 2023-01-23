//
//  UserDefaults+Extension.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 07.12.2022.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let value = container.object(forKey: key) as? Value ?? defaultValue
            SBLogger.log("⬆️ Get value: '\((value as? String) ?? "none")' from key: '\(key)'")
            return value
        }
        set {
            container.set(newValue, forKey: key)
            SBLogger.log("⬇️ Set value: '\((newValue as? String) ?? "none")' for key: '\(key)'")
        }
    }
}

extension UserDefaults {
    @UserDefault(key: "selectedBank", defaultValue: nil)
    static var bankApp: String?
}
