//
//  HelperFeatureModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

private extension MetricsValue {
    
    static let makeTransfer = MetricsValue(rawValue: "MakeTransfer")
    static let makeCard = MetricsValue(rawValue: "MakeCard")
    static let bnpl = MetricsValue(rawValue: "BNPL")
}

enum HelperType: Hashable, CaseIterable {
    
    case sbp
    case credit
    case bnpl
}

protocol HelperFeatureModulePresenting: NSObject {
    
    var featureCount: Int { get }
    func identifiresForSection(_ section: PaymentFeatureSection) -> [Int]
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectPaymentItem(at indexPath: IndexPath)
    func viewDidLoad()
    
    var view: (IHelperFeatureModuleVC & ModuleVC)? { get set }
}

final class HelperFeatureModulePresenter: NSObject, HelperFeatureModulePresenting {
    
    private var activeFeatures: [HelperType] {
        avaliableBunners()
    }
    
    var featureCount: Int {
        
        activeFeatures.count
    }
    
    weak var view: (IHelperFeatureModuleVC & ModuleVC)?
    private let router: PaymentRouting
    private let analytics: AnalyticsManager
    private var userService: UserService
    private let completionManager: CompletionManager
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private var authService: AuthService
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private let partPayService: PartPayService
    private let helperConfigManager: HelperConfigManager
    private let biometricAuthProvider: BiometricAuthProviderProtocol
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsManager,
         bankManager: BankAppManager,
         completionManager: CompletionManager,
         alertService: AlertService,
         authService: AuthService,
         secureChallengeService: SecureChallengeService,
         authManager: AuthManager,
         biometricAuthProvider: BiometricAuthProviderProtocol,
         partPayService: PartPayService,
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
        self.partPayService = partPayService
        self.helperConfigManager = helperConfigManager
        self.biometricAuthProvider = biometricAuthProvider
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
    }
    
    func identifiresForSection(_ section: PaymentFeatureSection) -> [Int] {
        
        return activeFeatures.compactMap({ $0.hashValue })
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        let feature = activeFeatures[indexPath.row]
        
        let event = EventBuilder().with(base: .Touch)
        
        switch feature {
        case .sbp:
            event.with(value: .makeTransfer)
        case .credit:
            event.with(value: .makeCard)
        case .bnpl:
            event.with(value: .bnpl)
        }
        
        analytics.send(event.build(), on: view?.contentParrent?.analyticsName)
        
        switch feature {
            
        case .sbp, .credit:
            
            guard let deeplinkIos = userService.user?.promoInfo.bannerList
                .first(where: { $0.bannerListType.equel(to: feature) })?.buttons
                .first?.deeplinkIos
            else { return }
            
            goTo(url: deeplinkIos)
        case .bnpl:
            cardTapped()
        }
    }
    
    private func cardTapped() {
         
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: .card)
            .build(), on: view?.contentParrent?.analyticsName ?? .None)
         
         guard userService.additionalCards else { return }
         guard let authMethod = authManager.authMethod else { return }
         
         guard !userService.getListCards else {
             presentListCards()
             return
         }
         
         switch authMethod {
         case .refresh:
             
             Task { @MainActor [biometricAuthProvider] in
                 
                 let canEvalute = await biometricAuthProvider.canEvalute()
                 
                 switch canEvalute {
                 case true:
                     let result = await biometricAuthProvider.evaluate()
                     
                     switch result {
                     case true:
                         analytics.send(EventBuilder()
                             .with(base: .LC)
                             .with(state: .Good)
                             .with(value: .bioAuth)
                             .build(), on: view?.contentParrent?.analyticsName ?? .None)
                         
                         self.presentListCards()
                     case false:
                         analytics.send(EventBuilder()
                             .with(base: .LC)
                             .with(state: .Fail)
                             .with(value: .bioAuth)
                             .build(), on: view?.contentParrent?.analyticsName ?? .None)
                         self.appAuth()
                     }
                 case false:
                     analytics.send(EventBuilder()
                         .with(base: .LC)
                         .with(state: .Fail)
                         .with(value: .bioAuth)
                         .build(), on: view?.contentParrent?.analyticsName ?? .None)
                     self.appAuth()
                 }
             }
             
         case .bank, .sid:
             
             presentListCards()
         }
     }
    
    private func appAuth() {
        
        Task {
            do {
                try await authService.appAuth()
                
                await self.view?.contentParrent?.showLoading()
                
                repeatAuth()
            } catch {
                if let error = error as? SDKError {
                    
                    if error.represents(.noData)
                        || error.represents(.bankAppError)
                        || error.represents(.bankAppNotFound) {
                        
                        await router.presentBankAppPicker()
                        self.repeatAuth()
                    } else {
                        await alertService.show(on: view?.contentParrent, type: .defaultError)
                        await completionManager.dismissCloseAction(view?.contentParrent)
                    }
                }
            }
        }
    }
    
    private func repeatAuth() {
        Task {
            
            try await self.authService.auth()
            
            self.authService.bankCheck = true
            self.presentListCards()
        }
    }
    
    private func presentListCards() {
        
        Task {
            
            await view?.contentParrent?.showLoading()
            
            guard let selectedCard = userService.selectedCard,
                  let user = userService.user else { return }
            
            userService.getListCards = true
            
            let finalCost = partPayService.bnplplanSelected
            ? partPayService.bnplplan?.graphBnpl?.parts.first?.amount
            : user.orderInfo.orderAmount.amount
            
            let card = try await router.presentCards(cards: user.paymentToolInfo.paymentTool,
                                                     cost: finalCost?.price(.RUB) ?? "",
                                                     selectedId: selectedCard.paymentID)
            await view?.contentParrent?.hideLoading(animate: true)
            userService.selectedCard = card
            view?.reloadData()
        }
    }
    
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        let feature = activeFeatures[indexPath.row]
        
        switch feature {
        case .sbp, .credit:
            
            guard let bunner = userService.user?.promoInfo.bannerList
                .first(where: { $0.bannerListType.equel(to: feature) })
            else { return nil }
            return HelperModelFactory.build(value: bunner)
        case .bnpl:
            
            guard let button = partPayService.bnplplan?.buttonBnpl else { return nil }
            return HelperModelFactory.build(button: button)
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
                
                await router.presentBankAppPicker()
                goTo(url: url)
            }
        }
    }

    @objc
    private func applicationDidBecomeActive() {
        // Если пользователь не смог получить обратный редирект
        // от банковского приложения и перешел самостоятельно
        
        Task {
            await router.presentBankAppPicker()
        }
    }
    
    private func avaliableBunners() -> [HelperType] {
        
        guard let user = userService.user else { return [] }
        
        var list = [HelperType]()
        
        if partPayService.bnplplanEnabled {
            list.append(.bnpl)
        }
        
        if helperConfigManager.helperAvaliable(bannerListType: .sbp)
           && user.promoInfo.bannerList.contains(where: { $0.bannerListType == .sbp }) {
            list.append(.sbp)
        }
        
        if helperConfigManager.helperAvaliable(bannerListType: .creditCard)
           && user.promoInfo.bannerList.contains(where: { $0.bannerListType == .sbp }) {
            list.append(.credit)
        }
        
        return list
    }
}
