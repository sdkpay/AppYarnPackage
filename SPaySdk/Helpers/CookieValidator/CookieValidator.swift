//
//  CookieValidator.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.08.2023.
//

import Foundation

enum CookieType: String {
    case geo = "X-Geo-Sticky"
    case refresh = "X-Sdk-Refresh-Data"
    case id = "X-Sdk-Id-Key"
}

enum CookieValidator {
    
    static let setCookieField = "SetCookie"

    static func contains(cookie: String, _ authCookie: CookieType) -> Bool {
        cookie.contains(authCookie.rawValue)
    }
    
    static func get(from cookie: String, authCookie: CookieType) -> String? {
        guard contains(cookie: cookie, authCookie) else { return nil }
        return cookie.slices(from: authCookie.rawValue, to: ",").first
    }
    
    static func formCookie(from cookies: [CookieType: String]) -> String {
        cookies.map{ formCookie($1, type: $0) }.joined()
    }
    
    static func formCookie(_ cookie: String, type: CookieType) -> String {
        type.rawValue + cookie + "; "
    }
    
    static func addCookie(_ part: (key: CookieType, value: String), to value: inout String) {
        let cookieString = formCookie(part.value, type: part.key)
        value = cookieString + value
    }
    
    static func addCookie(_ part: String, to value: inout String) {
        value = part + "; " + value
    }
}
