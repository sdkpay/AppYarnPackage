//
//  BaseRequestManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 09.02.2023.
//

import Foundation

final class AuthRequestManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: AuthRequestManager = DefaultAuthRequestManager(authManager: container.resolve())
        container.register(service: service)
    }
}

protocol AuthRequestManager {
    var headers: HTTPHeaders { get }
}

final class DefaultAuthRequestManager: AuthRequestManager {
    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        if let cookie = authManager.cookie {
            headers["Cookie"] = cookie
        }
        if let pod = authManager.pod {
            headers["x-pod-sticky"] = pod
        }
        return headers
    }
    
    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }
}
