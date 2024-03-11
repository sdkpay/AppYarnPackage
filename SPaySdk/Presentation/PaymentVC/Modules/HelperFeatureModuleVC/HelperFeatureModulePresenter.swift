//
//  HelperFeatureModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

enum HelperSection: Int, CaseIterable {
    case features
}

protocol HelperFeatureModulePresenting: NSObject {
    
    var featureCount: Int { get }
    func identifiresForSection(_ section: HelperSection) -> [Int]
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectPaymentItem(at indexPath: IndexPath)
    func viewDidLoad()
    
    var view: (IHelperFeatureModuleVC & ModuleVC)? { get set }
}

final class HelperFeatureModulePresenter: NSObject, HelperFeatureModulePresenting {

    private var activeFeatures: [BannerList] {
        configBanners()
    }
    
    var featureCount: Int {
        
        activeFeatures.count
    }
    
    weak var view: (IHelperFeatureModuleVC & ModuleVC)?
    private let router: PaymentRouting
    private let analytics: AnalyticsService
    private var userService: UserService
    private let completionManager: CompletionManager
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private var authService: AuthService
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private let helperConfigManager: HelperConfigManager
    
    private let screenEvent = [AnalyticsKey.View: AnlyticsScreenEvent.PaymentVC.rawValue]
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsService,
         bankManager: BankAppManager,
         completionManager: CompletionManager,
         alertService: AlertService,
         authService: AuthService,
         secureChallengeService: SecureChallengeService,
         authManager: AuthManager,
         helperConfigManager: HelperConfigManager) {
        self.router = router
        self.sdkManager = manager
        self.userService = userService
        self.completionManager = completionManager
        self.analytics = analytics
        self.authService = authService
        self.alertService = alertService
        self.bankManager = bankManager
        self.authManager = authManager
        self.helperConfigManager = helperConfigManager
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
    }

    func identifiresForSection(_ section: HelperSection) -> [Int] {
        
        return activeFeatures.compactMap({ $0.hashValue })
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        guard let section = HelperSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .features:
            
            let helper = activeFeatures[indexPath.row]
            
            guard let deeplinkIos = helper.buttons.first?.deeplinkIos else { return }
            goTo(url: deeplinkIos)
        }
    }
    
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let section = HelperSection(rawValue: indexPath.section) else { return nil }

        switch section {
        case .features:
            
            let helper = activeFeatures[indexPath.row]
            
            return HelperModelFactory.build(indexPath, value: helper)
        }
    }
    
    private func configViews() {

        view?.addSnapShot()
    }
    
    private func goTo(url: String) {
        
        completionManager.dismissCloseAction(view?.contentParrent)
        guard let fullUrl = bankManager.configUrl(path: url, type: .util) else { return }
        
        Task {
            
            let result = await router.open(fullUrl)
            
            if !result {
                
                router.presentBankAppPicker {
                    self.goTo(url: url)
                }
            }
        }
    }
    
    private func appAuth() {
        analytics.sendEvent(.LCBankAppAuth, with: screenEvent)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        Task {
            do {
                try await authService.appAuth()
                
                await self.view?.contentParrent?.showLoading()
                await NotificationCenter.default.removeObserver(self,
                                                                name: UIApplication.didBecomeActiveNotification,
                                                                object: nil)
                
                self.analytics.sendEvent(.LCBankAppAuthGood, with: self.screenEvent)
            } catch {
                if let error = error as? SDKError {
                    
                    self.analytics.sendEvent(.LCBankAppAuthFail, with: self.screenEvent)
                    
                    if error.represents(.noData) {
                        
                        await MainActor.run {
                            router.presentBankAppPicker {
                            }
                        }
                    } else {
                        await alertService.show(on: view?.contentParrent, type: .defaultError)
                        await completionManager.dismissCloseAction(view?.contentParrent)
                    }
                }
            }
        }
    }
    
    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        
        Task {
            await MainActor.run {
                router.presentBankAppPicker {
                }
            }
        }
    }
    
    private func configBanners() -> [BannerList] {

        guard let user = userService.user else { return [] }
        
        let avaliableBunners = avaliableBunners()
        
        return user.promoInfo.bannerList.filter { list in
            avaliableBunners.contains(list.bannerListType)
        }
    }
    
    private func avaliableBunners() -> [BannerListType] {
        
        var list = [BannerListType]()
        
        if helperConfigManager.helperAvaliable(bannerListType: .sbp) {
            list.append(.sbp)
        }
        
        if helperConfigManager.helperAvaliable(bannerListType: .creditCard) {
            list.append(.creditCard)
        }
        
        return list
    }
}
