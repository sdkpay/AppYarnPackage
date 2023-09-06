//
//  SecureCookieStorage.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.08.2023.
//

import Foundation

final class SecureHTTPCookie: HTTPCookie, NSSecureCoding {
    required init?(coder: NSCoder) {
        var properties = [HTTPCookiePropertyKey: Any]()
        let version = coder.decodeInteger(forKey: "version")
        let name = coder.decodeObject(of: NSString.self, forKey: "name") as String?
        let value = coder.decodeObject(of: NSString.self, forKey: "value") as String?
        let expiresDate = coder.decodeObject(of: NSDate.self, forKey: "expiresDate") as Date?
        let isSessionOnly = coder.decodeBool(forKey: "isSessionOnly")
        let domain = coder.decodeObject(of: NSString.self, forKey: "domain") as String?
        let path = coder.decodeObject(of: NSString.self, forKey: "path") as String?
        let isSecure = coder.decodeBool(forKey: "isSecure")
        let isHTTPOnly = coder.decodeBool(forKey: "isHTTPOnly")
        
        let comment = coder.decodeObject(of: NSString.self, forKey: "comment") as String?
        let commentURL = coder.decodeObject(of: NSURL.self, forKey: "commentURL") as URL?
        let portList: [NSNumber]?
        if #available(iOS 14.0, *) {
            portList = coder.decodeArrayOfObjects(ofClass: NSNumber.self, forKey: "portList")
        } else {
            portList = coder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "portList") as? [NSNumber]
        }
        
        let sameSitePolicy = coder.decodeObject(of: NSString.self, forKey: "sameSitePolicy") as String?
        
        properties[HTTPCookiePropertyKey.version] = version
        properties[HTTPCookiePropertyKey.name] = name
        properties[HTTPCookiePropertyKey.value] = value
        properties[HTTPCookiePropertyKey.domain] = domain
        properties[HTTPCookiePropertyKey.path] = path
        properties[HTTPCookiePropertyKey.secure] = isSecure ? "TRUE" : nil
        properties[HTTPCookiePropertyKey.expires] = expiresDate
        properties[HTTPCookiePropertyKey.comment] = comment
        properties[HTTPCookiePropertyKey.commentURL] = commentURL
        properties[HTTPCookiePropertyKey.discard] = isSessionOnly ? "TRUE" : nil
        properties[HTTPCookiePropertyKey.maximumAge] = expiresDate
        properties[HTTPCookiePropertyKey.port] = portList
        properties[HTTPCookiePropertyKey("HttpOnly")] = isHTTPOnly ? "TRUE" : nil
        if #available(iOS 13.0, *) {
            if let sameSitePolicyValue = sameSitePolicy {
                properties[HTTPCookiePropertyKey.sameSitePolicy] = HTTPCookieStringPolicy(rawValue: sameSitePolicyValue)
            }
        }
        
        super.init(properties: properties)
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    init?(with cookieProperties: [HTTPCookiePropertyKey: Any]) {
        super.init(properties: cookieProperties)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.version, forKey: "version")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.value, forKey: "value")
        aCoder.encode(self.expiresDate, forKey: "expiresDate")
        aCoder.encode(self.isSessionOnly, forKey: "isSessionOnly")
        aCoder.encode(self.domain, forKey: "domain")
        aCoder.encode(self.path, forKey: "path")
        aCoder.encode(self.isSecure, forKey: "isSecure")
        aCoder.encode(self.isHTTPOnly, forKey: "isHTTPOnly")
        aCoder.encode(self.comment, forKey: "comment")
        aCoder.encode(self.commentURL, forKey: "commentURL")
        aCoder.encode(self.portList, forKey: "portList")
        if #available(iOS 13.0, *) {
            aCoder.encode(self.sameSitePolicy, forKey: "sameSitePolicy")
        }
    }
}

final class CookieStorageAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: CookieStorage = DefaultCookieStorage(storage: container.resolve())
            return service
        }
    }
}

protocol CookieStorage {
    func setCookie(cookie: HTTPCookie, for key: Cookies)
    func getCookie(for key: Cookies) -> HTTPCookie?
    func cleanCookie()
}

final class DefaultCookieStorage: CookieStorage {
    
    private let storage: KeychainStorage

    init(storage: KeychainStorage) {
        self.storage = storage
    }
    
    func setCookie(cookie: HTTPCookie, for key: Cookies) {
        guard let cookiesData = try? NSKeyedArchiver.archivedData(withRootObject: cookie, requiringSecureCoding: false) else { return }
        guard let key = key.storage else { return }
        try? storage.setData(cookiesData, for: key)
    }
    
    func getCookie(for key: Cookies) -> HTTPCookie? {
        guard let key = key.storage else { return nil }
        
        guard let cookieData = try? storage.getData(for: key) else { return nil }
        
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cookieData) as? HTTPCookie
    }
    
    func cleanCookie() {
        try? storage.delete(StorageKey.cookieId.rawValue)
        try? storage.delete(StorageKey.cookieData.rawValue)
    }
}
