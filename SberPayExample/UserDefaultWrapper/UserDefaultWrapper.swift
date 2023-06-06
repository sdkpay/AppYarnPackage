//
//  UserDefaultWrapper.swift
//  SPaySdkExample
//
//  Created by Ипатов Александр Станиславович on 25.05.2023.
//

import Foundation

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

public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let data = container.object(forKey: key) as? Data ?? Data()
            let value = data.decode(to: Value.self) ?? defaultValue
            return value
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                guard let data = newValue.data else { return }
                container.set(data, forKey: key)
            }
        }
    }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
    init(key: String, _ container: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, container: container)
    }
}
