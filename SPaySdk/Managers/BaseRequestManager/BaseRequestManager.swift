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
    }
}

enum Cookies {
    static let geo = "X-Geo-Sticky"
    static let refreshData = "X-Sdk-Refresh-Data"
    static let id = "X-Sdk-Id-Key"
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
}

final class DefaultBaseRequestManager: BaseRequestManager {
    var geoCookie: HTTPCookie?
    var pod: String?
    
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
        
        headers[.Headers.os] = UIDevice.current.fullSystemVersion
        headers[.Headers.deviceName] = Device.current.rawValue
        return headers
    }

    init(authManager: AuthManager,
         storage: KeychainStorage) {
        self.authManager = authManager
        self.storage = storage
    }
}
