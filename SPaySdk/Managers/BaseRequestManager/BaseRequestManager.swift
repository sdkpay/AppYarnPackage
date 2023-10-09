//
//  AuthRequestManager.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import UIKit

extension String {
    enum Headers {
        static let cookie = "Cookie"
        static let setCookie = "Set-Cookie"
        static let pod = "x-pod-sticky"
        static let rqUID = "RqUID"
        static let localTime = "UserTm"
        static let lang = "Accept-Language"
        static let authorization = "Authorization"
        static let os = "OS"
        static let deviceName = "deviceName"
        static let orderNumber = "orderNumber"
        static let b3TraceId = "x-b3-traceid"
        static let b3SpanId = "x-b3-spanid"
    }
}

enum Cookies: String {
    case geo = "X-Geo-Sticky"
    case refreshData = "X-Sdk-Refresh-Data"
    case id = "X-Sdk-Id-Key"
    
    var storage: StorageKey? {
        switch self {
        case .geo:
            return nil
        case .refreshData:
            return .cookieData
        case .id:
            return .cookieId
        }
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
    var geoCookie: HTTPCookie? { get set }
    var pod: String? { get set }
    func generateB3Cookie()
}

final class DefaultBaseRequestManager: BaseRequestManager {
    
    var geoCookie: HTTPCookie?
    var pod: String?
    var b3TraceId: String?
    var b3SpanId: String?
    
    private let authManager: AuthManager
    private let storage: KeychainStorage

    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        if let pod = pod {
            headers[.Headers.pod] = pod
        }
        if let apiKey = authManager.apiKey {
            headers[.Headers.authorization] = apiKey
        }
        if let lang = authManager.lang {
            headers[.Headers.lang] = lang
        }
        if let orderNumber = authManager.orderNumber {
            headers[.Headers.orderNumber] = orderNumber
        }
        if let b3TraceId = b3TraceId {
            headers[.Headers.b3TraceId] = b3TraceId
        }
        if let b3SpanId = b3SpanId {
            headers[.Headers.b3SpanId] = b3SpanId
        }
        
        headers[.Headers.os] = UIDevice.current.fullSystemVersion
        headers[.Headers.deviceName] = Device.current.rawValue
        return headers
    }

    init(authManager: AuthManager,
         storage: KeychainStorage) {
        self.authManager = authManager
        self.storage = storage
    }
    
    func generateB3Cookie() {
        b3TraceId = .generateRandom(with: 32)
        b3SpanId = .generateRandom(with: 16)
    }
}
