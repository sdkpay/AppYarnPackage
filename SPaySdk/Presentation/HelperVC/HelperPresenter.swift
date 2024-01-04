//
//  HelperPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 19.11.2023.
//

import UIKit

protocol HelperPresenting {
    func viewDidLoad()
    func confirmTapped() async
    func cancelTapped()
}

final class HelperPresenter: HelperPresenting {
    
    weak var view: (IHelperVC & ContentVC)?

    private let router: HelperRouting
    private let analytics: AnalyticsService
    private let completionManager: CompletionManager
    private let userService: UserService
    private let bankAppManager: BankAppManager
    private let featureToggle: FeatureToggleService
    private let helperConfigManager: HelperConfigManager
    
    init(_ router: HelperRouting,
         completionManager: CompletionManager,
         userService: UserService,
         bankAppManager: BankAppManager,
         featureToggle: FeatureToggleService,
         helperConfigManager: HelperConfigManager,
         analytics: AnalyticsService) {
        self.router = router
        self.analytics = analytics
        self.userService = userService
        self.featureToggle = featureToggle
        self.completionManager = completionManager
        self.helperConfigManager = helperConfigManager
        self.bankAppManager = bankAppManager
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func viewDidLoad() {
        
        guard let user = userService.user else { return }
        guard let banner = user.promoInfo.bannerList.first(where: { $0.bannerListType == .debitCard }) else { return }
        
        let needCard = helperConfigManager.config.debitCard && featureToggle.isEnabled(.newDebitCard)
        
        view?.setup(title: banner.title,
                    subtitle: banner.text,
                    iconUrl: banner.iconUrl,
                    needButton: needCard)
    }
    
    @MainActor
    func confirmTapped() async {
        
        guard let path = userService.user?.promoInfo.bannerList.first(where: { $0.bannerListType == .debitCard })?.deeplinkIos else {
            await MainActor.run { completionManager.dismissCloseAction(view) }
            return
        }
 
        guard let link = bankAppManager.configUrl(path: path, type: .util) else {
            await MainActor.run { completionManager.dismissCloseAction(view) }
            return
        }
        
        await MainActor.run { completionManager.dismissCloseAction(view) }
        
        let isOpened = await router.open(link)
        
        if !isOpened {
            
            router.presentBankAppPicker(completion: {
                
                Task {
                    await self.confirmTapped()
                }
            })
        }
    }
    
    func cancelTapped() {
        
        completionManager.dismissCloseAction(view)
    }
}
