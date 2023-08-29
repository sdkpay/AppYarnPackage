//
//  AuthRequestManager.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import Foundation

extension String {
    enum Headers {
        static let cookie = "Cookie"
        static let setCookie = "Set-Cookie"
        static let pod = "x-pod-sticky"
        static let rqUID = "RqUID"
        static let localTime = "UserTm"
        static let lang = "Accept-Language"
        static let authorization = "Authorization"
    }
}

final class BaseRequestManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: BaseRequestManager = DefaultBaseRequestManager(authManager: container.resolve(),
                                                                        storage: container.resolve())
            return service
        }
    }
}

protocol BaseRequestManager {
    var headers: HTTPHeaders { get }
    var cookie: String? { get set }
    var pod: String? { get set }
}

final class DefaultBaseRequestManager: BaseRequestManager {
    var cookie: String? {
        get {
            getFullCookie()
        } set {
            guard let newValue else { return }
            saveCookie(newValue)
        }
    }
    var pod: String?
    
    private let authManager: AuthManager
    private let storage: KeychainStorage
    private var geoCookie: String?

    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        if let cookie = cookie {
            headers[.Headers.cookie] = cookie
        }
        if let pod = pod {
            headers[.Headers.pod] = pod
        }
        if let apiKey = authManager.apiKey {
            headers[.Headers.authorization] = apiKey
        }
        if let lang = authManager.lang {
            headers[.Headers.lang] = lang
        }
        return headers
    }
    
    private func saveCookie(_ cookieString: String) {
        if let geo = CookieValidator.get(from: cookieString, authCookie: .geo) {
            geoCookie = geo
        }

        if let idCookie = CookieValidator.get(from: cookieString, authCookie: .id) {
            try? storage.set(idCookie, .cookieId)
        }

        if let refresh = CookieValidator.get(from: cookieString, authCookie: .refresh) {
            try? storage.set(refresh, .cookieData)
        }
    }
    
    private func getFullCookie() -> String? {
        var fullCookie: String = ""
        
        if let geoCookie {
            fullCookie.append(formCookie(geoCookie, type: .geo))
        }
        
        if let cookieData = try? storage.get(.cookieData) {
            fullCookie.append(formCookie(cookieData, type: .refresh))
        }
        
        if let cookieId = try? storage.get(.cookieId) {
            fullCookie.append(formCookie(cookieId, type: .id))
        }
        
        if fullCookie.isEmpty {
            return nil
        } else {
            return String(fullCookie.dropLast(2))
        }
    }
    
    private func formCookie(_ cookie: String, type: AuthCookie) -> String {
        type.rawValue + cookie + ", "
    }
    
    init(authManager: AuthManager,
         storage: KeychainStorage) {
        self.authManager = authManager
        self.storage = storage
    }
}

enum AuthCookie: String {
    case geo = "X-Geo-Sticky"
    case refresh = "X-Sdk-Refresh-Data"
    case id = "X-Sdk-Id-Key"
}

enum CookieValidator {

    static func contains(cookie: String, _ authCookie: AuthCookie) -> Bool {
        cookie.contains(authCookie.rawValue)
    }
    
    static func get(from cookie: String, authCookie: AuthCookie) -> String? {
        guard contains(cookie: cookie, authCookie) else { return nil }
        return cookie.slices(from: authCookie.rawValue, to: ",").first
    }
}
