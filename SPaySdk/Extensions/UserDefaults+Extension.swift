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
    case bankApps
    case images
    case offerTitle
    case certKeys
    case featureToggle
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: DefaultsKey
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let data = container.object(forKey: key.rawValue) as? Data ?? Data()
            let value = data.decode(to: Value.self) ?? defaultValue
            return value
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key.rawValue)
            } else {
                guard let data = newValue.data else { return }
                container.set(data, forKey: key.rawValue)
            }
        }
    }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
    init(key: DefaultsKey, _ container: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, container: container)
    }
}


extension UserDefaults {
    static func removeValue(for key: DefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

extension UserDefaults {
    @UserDefault(key: .selectedBank)
    static var bankApp: Int?
    
    @UserDefault(key: .localization)
    static var localization: Localization?
    
    @UserDefault(key: .schemas)
    static var schemas: Schemas?
    
    @UserDefault(key: .images)
    static var images: Images?
    
    @UserDefault(key: .bankApps,
                 defaultValue: [])
    static var bankApps: [BankApp]?
    
    @UserDefault(key: .certKeys)
    static var certKeys: [String]?
    
    @UserDefault(key: .featureToggle, defaultValue: [])
    static var featureToggle: [FeaturesToggle]
}
