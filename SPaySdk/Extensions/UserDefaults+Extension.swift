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
}

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: DefaultsKey
    let defaultValue: Value?
    var container = UserDefaults.standard

    var wrappedValue: Value? {
        get {
            let data = container.object(forKey: key.rawValue) as? Data ?? Data()
            let value = data.decode(to: Value.self)
            SBLogger.log(level: .debug(level: .storage),
                         "⬆️ Get value: '\((value as? String) ?? "none")' from key: '\(key.rawValue)'")
            return value
        }
        set {
            guard let data = newValue.data else { return }
            container.set(data, forKey: key.rawValue)
            guard let newValue = newValue else { return }
            SBLogger.log(level: .debug(level: .storage),
                         "⬇️ Set value: '\(newValue)' for key: '\(key.rawValue)'")
        }
    }
}

extension UserDefaults {
    static func removeValue(for key: DefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

extension UserDefaults {
    @UserDefault(key: .selectedBank, defaultValue: "foo")
    static var bankApp: String?
    
    @UserDefault(key: .localization,
                 defaultValue: Localization(authTitle: "foo", payLoading: "foo"))
    static var localization: Localization?
    
    @UserDefault(key: .schemas,
                 defaultValue: Schemas(payLinkFirstApp: "foo",
                                       payLinkSecondApp: "foo",
                                       dynatraceUrl: "foo",
                                       dynatraceId: "foo"))
    static var schemas: Schemas?
    
    @UserDefault(key: .images,
                 defaultValue: Images(logoIcon: "foo",
                                      logoClear: "foo"))
    static var images: Images?
    
    @UserDefault(key: .bankApps,
                 defaultValue: [BankApp(name: "", link: "", icon: "")])
    static var bankApps: [BankApp]?
    
    @UserDefault(key: .certKeys, defaultValue: [String]())
    static var certKeys: [String]?
}
