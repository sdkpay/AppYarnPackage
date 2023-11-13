//
//  LogoutPresenter.swift
//  SPaySdk
//
//  Created by Арсений on 17.08.2023.
//

import Foundation
import UIKit

protocol LogoutPresenting {
    func back()
    func logout()
    func getNumber() -> String?
    func getName() -> String 
}

final class LogoutPresenter: LogoutPresenting {
    
    weak var view: (ILogoutVC & ContentVC)?
    private let sdkManager: SDKManager
    private var storage: CookieStorage
    private var authManager: AuthManager
    private let userService: UserService
    private let completionManager: CompletionManager
    
    init(sdkManager: SDKManager,
         storage: CookieStorage,
         userService: UserService,
         authManager: AuthManager,
         completionManager: CompletionManager) {
        self.sdkManager = sdkManager
        self.storage = storage
        self.authManager = authManager
        self.userService = userService
        self.completionManager = completionManager
    }
    
    func getNumber() -> String? {
        authManager.userInfo?.mobilePhone
    }
    
    func getName() -> String {
        (authManager.userInfo?.firstName ?? "") + " " + (authManager.userInfo?.lastName ?? "")
    }
    
    @MainActor
    func back() {
        view?.contentNavigationController?.popViewController(animated: true, completion: nil)
    }
    
    func logout() {
        userService.clearData()
        storage.cleanCookie()
        completionManager.dismissCloseAction(view)
    }
}
