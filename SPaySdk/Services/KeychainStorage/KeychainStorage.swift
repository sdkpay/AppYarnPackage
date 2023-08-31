//
//  KeychainStorage.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 07.08.2023.
//

import Foundation
import Security

enum StorageKey: String {
    case cookieData
    case cookieId
}

enum KeychainError: Error {
    case itemAlreadyExist
    case itemNotFound
    case errorStatus(String?)
    case badFormat
    
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
    func register(in container: LocatorService) {
        container.register {
            let service: KeychainStorage = DefaultKeychainStorage()
            return service
        }
    }
}

protocol KeychainStorage {
    func exists(_ key: StorageKey) throws -> Bool
    func set(_ value: String, _ key: StorageKey) throws
    func setData(_ value: Data, for key: StorageKey) throws
    func getData(for key: StorageKey) throws -> Data?
    func get(_ key: StorageKey) throws -> String?
    func delete(_ key: String) throws
    func deleteAll() throws
}

final class DefaultKeychainStorage: KeychainStorage {
    private let service = Bundle.sdkBundle.displayName ?? "Default"
    
    func exists(_ key: StorageKey) throws -> Bool {
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecAttrService: service,
            kSecReturnData: false
        ] as NSDictionary, nil)
        
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
    
    func getData(for key: StorageKey) throws -> Data? {
        var result: AnyObject?
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecAttrService: service,
            kSecReturnData: true
        ] as NSDictionary, &result)
        if status == errSecSuccess {
            return result as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw KeychainError(status: status)
        }
    }
    
    func get(_ key: StorageKey) throws -> String? {
        do {
            guard let data = try getData(for: key) else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            throw error
        }
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
