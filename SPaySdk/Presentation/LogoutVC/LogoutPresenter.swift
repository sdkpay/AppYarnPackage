//
//  LogoutPresenter.swift
//  SPaySdk
//
//  Created by Арсений on 17.08.2023.
//

import Foundation

protocol LogoutPresenting {
    func back()
    func logout()
}

final class LogoutPresenter: LogoutPresenting {
    
    weak var view: (ILogoutVC & ContentVC)?
    private let sdkManager: SDKManager
    private var storage: KeychainStorage
    
    init(sdkManager: SDKManager, storage: KeychainStorage) {
        self.sdkManager = sdkManager
        self.storage = storage
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
