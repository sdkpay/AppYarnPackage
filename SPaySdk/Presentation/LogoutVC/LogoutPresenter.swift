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
    func viewDidAppear()
    func viewDidDisappear()
}

final class LogoutPresenter: LogoutPresenting {
    
    weak var view: (ILogoutVC & ContentVC)?
    private let sdkManager: SDKManager
    private var storage: CookieStorage
    private var authManager: AuthManager
    private let userService: UserService
    private let completionManager: CompletionManager
    private let analytics: AnalyticsService
    
    private let screenEvent = [AnalyticsKey.view: AnlyticsScreenEvent.ProfileView.rawValue]
    
    init(sdkManager: SDKManager,
         storage: CookieStorage,
         userService: UserService,
         authManager: AuthManager,
         analytics: AnalyticsService,
         completionManager: CompletionManager) {
        self.sdkManager = sdkManager
        self.storage = storage
        self.analytics = analytics
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
    
    func viewDidAppear() {
        analytics.sendEvent(.LCProfileViewAppeared, with: screenEvent)
    }
    
    func viewDidDisappear() {
        analytics.sendEvent(.LCProfileViewDisappeared, with: screenEvent)
    }
    
    func back() {
        view?.contentNavigationController?.popViewController(animated: true, completion: nil)
        analytics.sendEvent(.TouchBack, with: screenEvent)
    }
    
    func logout() {
        userService.clearData()
        storage.cleanCookie()
        analytics.sendEvent(.STRemoveRefresh, with: screenEvent)
        completionManager.dismissCloseAction(view)
        analytics.sendEvent(.TouchLogOut, with: screenEvent)
    }
}
