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
    private var storage: KeychainStorage
    private var authManager: AuthManager
    
    init(sdkManager: SDKManager, storage: KeychainStorage, authManager: AuthManager) {
        self.sdkManager = sdkManager
        self.storage = storage
        self.authManager = authManager
    }
    
    func getNumber() -> String? {
        authManager.userInfo?.mobilePhone
    }
    
    func getName() -> String {
        (authManager.userInfo?.firstName ?? "") + " " + (authManager.userInfo?.lastName ?? "")
    }
    
    func back() {
        view?.contentNavigationController?.popViewController(animated: true, completion: nil)
    }
    
    func logout() {
        try? storage.deleteAll()
        view?.dismiss(animated: true) {
            self.sdkManager.completionWithError(error: .cancelled)
        }
    }
}
