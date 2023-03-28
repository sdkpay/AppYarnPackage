//
//  UserDefaults+Extension.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 07.12.2022.
//

import Foundation

enum DefaultsKey: String {
    case selectedBank
    case localization
    case schemas
    case images
}

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: DefaultsKey
    let defaultValue: Value?
    var container: UserDefaults = .standard

    var wrappedValue: Value? {
        get {
            let data = container.object(forKey: key.rawValue) as? Data ?? Data()
            let value = data.decode(to: Value.self)
            SBLogger.log("⬆️ Get value: '\((value as? String) ?? "none")' from key: '\(key.rawValue)'")
            return value
        }
        set {
            guard let data = newValue.data else { return }
            container.set(data, forKey: key.rawValue)
            guard let newValue = newValue else { return }
            SBLogger.log("⬇️ Set value: '\(newValue)' for key: '\(key.rawValue)'")
        }
    }
}

extension UserDefaults {
    static func removeValue(for key: DefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

extension UserDefaults {
    @UserDefault(key: .selectedBank, defaultValue: "")
    static var bankApp: String?
    
    @UserDefault(key: .localization, defaultValue: nil)
    static var localization: Localization?
    
    @UserDefault(key: .schemas, defaultValue: nil)
    static var schemas: Schemas?
    
    @UserDefault(key: .images, defaultValue: nil)
    static var images: Images?
}
