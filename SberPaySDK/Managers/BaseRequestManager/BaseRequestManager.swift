//
//  AuthRequestManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import Foundation

extension String {
    enum Headers {
        static let cookie = "Cookie"
        static let pod = "x-pod-sticky"
        static let rqUID = "RqUID"
        static let localTime = "UserTm"
        static let lang = "Accept-Language"
    }
}

final class BaseRequestManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: BaseRequestManager = DefaultBaseRequestManager()
        container.register(service: service)
    }
}

protocol BaseRequestManager {
    var headers: HTTPHeaders { get }
    var cookie: String? { get set }
    var pod: String? { get set }
}

final class DefaultBaseRequestManager: BaseRequestManager {
    var cookie: String?
    var pod: String?

    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        if let cookie = cookie {
            headers[.Headers.cookie] = cookie
        }
        if let pod = pod {
            headers[.Headers.pod] = pod
        }
        return headers
    }
}
