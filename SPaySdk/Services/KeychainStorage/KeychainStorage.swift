//
//  KeychainStorage.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 07.08.2023.
//

import Foundation
import Security

private enum SharedKeychainConstants {
    
    static let groupEnding = "ru.sid.iphone.shared"
    static let appIdKey = "AppIdentifierPrefix"
}


enum StorageKey: String {
    
    case cookieData
    case cookieId
    case appToken
}

enum StorageMode {
    
    case local
    case sid
    
    var service: String {
        switch self {
        case .local:
            return Bundle.sdkBundle.displayName
        case .sid:
            return "sber_id_app_token"
        }
    }
    
    var group: String? {
        switch self {
        case .local:
            return nil
        case .sid:
            guard let appIdPrefix = Bundle.main.object(forInfoDictionaryKey: SharedKeychainConstants.appIdKey) as? String else { return nil }
            return appIdPrefix + SharedKeychainConstants.groupEnding
        }
    }
}

enum KeychainError: Error {
    case itemAlreadyExist
    case itemNotFound
    case errorStatus(String?)
    case badFormat
    case noData
    case decodeError
    
    init(status: OSStatus) {
        switch status {
        case errSecDuplicateItem:
            self = .itemAlreadyExist
        case errSecItemNotFound:
            self = .itemNotFound
        default:
            let message = SecCopyErrorMessageString(status, nil) as String?
            self = .errorStatus(message)
        }
    }
}

final class KeychainStorageAssembly: Assembly {
    
    var type = ObjectIdentifier(KeychainStorage.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: KeychainStorage = DefaultKeychainStorage()
            return service
        }
    }
}

protocol KeychainStorage {
    func exists(_ key: StorageKey, mode: StorageMode) throws -> Bool
    func set(_ value: String, _ key: StorageKey) throws
    func setData(_ value: Data, for key: StorageKey) throws
    func getData(for key: StorageKey, mode: StorageMode) throws -> Data?
    func get(_ key: StorageKey, mode: StorageMode) throws -> String?
    func get<T>(for key: StorageKey,
                mode: StorageMode,
                to type: T.Type) throws -> T where T: Codable
    func delete(_ key: String) throws
    func deleteAll() throws
}

extension KeychainStorage {
    func exists(_ key: StorageKey, mode: StorageMode = .local) throws -> Bool {
        try exists(key, mode: mode)
    }
    
    func getData(for key: StorageKey, mode: StorageMode = .local) throws -> Data? {
        try getData(for: key, mode: mode)
    }
    
    func get(_ key: StorageKey, mode: StorageMode = .local) throws -> String? {
        try get(key, mode: mode)
    }
}

final class DefaultKeychainStorage: KeychainStorage, ResponseDecoder {
    
    private let service = Bundle.sdkBundle.displayName
    
    func exists(_ key: StorageKey, mode: StorageMode) throws -> Bool {
        
        var cfDictionaty: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: mode.service,
            kSecReturnData: false
        ]
        
        if mode == .local {
            cfDictionaty[kSecAttrAccount] = key.rawValue
        }
        
        if let group = mode.group {
            cfDictionaty[kSecAttrAccessGroup] = group
            cfDictionaty[kSecMatchLimit] = kSecMatchLimitOne
        }
        
        let status = SecItemCopyMatching(cfDictionaty as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecItemNotFound {
            return false
        } else {
            throw KeychainError(status: status)
        }
    }
    
    func set(_ value: String, _ key: StorageKey) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            throw KeychainError.badFormat
        }
        
        try setData(data, for: key)
    }
    
    func setData(_ value: Data, for key: StorageKey) throws {
        if try exists(key) {
            try update(value: value, for: key)
        } else {
            try add(value: value, for: key)
        }
    }
    
    func getData(for key: StorageKey, mode: StorageMode) throws -> Data? {
        
        var result: AnyObject?
        
        var cfDictionaty: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: mode.service,
            kSecReturnData: true
        ]
        
        if mode == .local {
            cfDictionaty[kSecAttrAccount] = key.rawValue
        }
        
        if let group = mode.group {
            cfDictionaty[kSecAttrAccessGroup] = group
            cfDictionaty[kSecMatchLimit] = kSecMatchLimitOne
        }
        
        let status = SecItemCopyMatching(cfDictionaty as CFDictionary, &result)
 
        if status == errSecSuccess {
            return result as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw KeychainError(status: status)
        }
    }
    
    func get(_ key: StorageKey, mode: StorageMode) throws -> String? {
        do {
            guard let data = try getData(for: key, mode: mode) else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            throw error
        }
    }

    func get<T>(for key: StorageKey,
                mode: StorageMode,
                to type: T.Type) throws -> T where T: Codable {
        
        guard let data = try getData(for: key, mode: mode) else { throw KeychainError.noData }
        return try self.decode(data: data, to: type)
    }
    
    func delete(_ key: String) throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service
        ] as NSDictionary)
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
    
    func deleteAll() throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword
        ] as NSDictionary)
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
    
    private func add(value: Data, for key: StorageKey) throws {
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecAttrService: service,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData: value
        ] as NSDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
    
    private func update(value: Data, for key: StorageKey) throws {
        let status = SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecAttrService: service
        ] as NSDictionary, [
            kSecValueData: value
        ] as NSDictionary)
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
}
