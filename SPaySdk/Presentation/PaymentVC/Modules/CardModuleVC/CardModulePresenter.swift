//
//  CardModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.04.2024.
//

import UIKit

enum CardSection: Int, CaseIterable {
    case card
}

protocol CardModulePresenting: NSObject {
    
    func identifiresForSection() -> [Int]
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectPaymentItem(at indexPath: IndexPath)
    func viewDidLoad()
    
    var view: (ICardModuleVC & ModuleVC)? { get set }
}

final class CardModulePresenter: NSObject, CardModulePresenting {
    
    weak var view: (ICardModuleVC & ModuleVC)?
    private let router: PaymentRouting
    private let analytics: AnalyticsManager
    private var userService: UserService
    private let paymentService: PaymentService
    private let locationManager: LocationManager
    private let completionManager: CompletionManager
    private let sdkManager: SDKManager
    private let authManager: AuthManager
    private var authService: AuthService
    private let alertService: AlertService
    private let bankManager: BankAppManager
    private var partPayService: PartPayService
    private let biometricAuthProvider: BiometricAuthProviderProtocol
    private let otpService: OTPService
    private let featureToggle: FeatureToggleService
    private var secureChallengeService: SecureChallengeService
    private var payAmountValidationManager: PayAmountValidationManager
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         analytics: AnalyticsManager,
         bankManager: BankAppManager,
         paymentService: PaymentService,
         locationManager: LocationManager,
         completionManager: CompletionManager,
         alertService: AlertService,
         authService: AuthService,
         partPayService: PartPayService,
         secureChallengeService: SecureChallengeService,
         authManager: AuthManager,
         biometricAuthProvider: BiometricAuthProviderProtocol,
         payAmountValidationManager: PayAmountValidationManager,
         featureToggle: FeatureToggleService,
         otpService: OTPService) {
        self.router = router
        self.sdkManager = manager
        self.userService = userService
        self.completionManager = completionManager
        self.analytics = analytics
        self.authService = authService
        self.paymentService = paymentService
        self.locationManager = locationManager
        self.alertService = alertService
        self.secureChallengeService = secureChallengeService
        self.partPayService = partPayService
        self.biometricAuthProvider = biometricAuthProvider
        self.bankManager = bankManager
        self.authManager = authManager
        self.otpService = otpService
        self.payAmountValidationManager = payAmountValidationManager
        self.featureToggle = featureToggle
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
    }
    
    func identifiresForSection() -> [Int] {
        
        if let paymentId = userService.selectedCard?.cardNumber.hash {
            return [paymentId]
        } else {
            return []
        }
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        cardTapped()
    }
    
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let selectedCard = userService.selectedCard else { return nil }
        return CardModelFactory.build(indexPath,
                                      selectedCard: selectedCard,
                                      additionalCards: userService.additionalCards,
                                      cardBalanceNeed: featureToggle.isEnabled(.cardBalance),
                                      compoundWalletNeed: featureToggle.isEnabled(.compoundWallet))
    }
    
    private func partPayTapped() {
        
        Task {
           await router.presentPartPay()
            configViews()
            view?.reloadData()
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
    
    private func presentListCards() {
        
        Task {
            
            await view?.contentParrent?.showLoading()
            
            guard let selectedCard = userService.selectedCard,
                  let user = userService.user else { return }
            
            userService.getListCards = true
            
            let finalCost = partPayService.bnplplanSelected
            ? partPayService.bnplplan?.graphBnpl?.parts.first?.amount
            : user.orderInfo.orderAmount.amount
            
            let card = try? await self.router.presentCards(cards: user.paymentToolInfo.paymentTool,
                                                           cost: finalCost?.price(.RUB) ?? "",
                                                           selectedId: selectedCard.paymentID)
            await view?.contentParrent?.hideLoading(animate: true)
            userService.selectedCard = card
            view?.reloadData()
        }
    }
    
    private func configViews() {
        
        view?.addSnapShot()
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
}

