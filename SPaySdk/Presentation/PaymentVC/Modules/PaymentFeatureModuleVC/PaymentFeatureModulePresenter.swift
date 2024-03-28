//
//  PaymentFeatureModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

extension MetricsValue {
    
    static let card = MetricsValue(rawValue: "Card")
}

enum PaymentSection: Int, CaseIterable {
    case features
    case card
}

enum PaymentFeature: Int, CaseIterable {
    case bnpl
}

protocol PaymentFeatureModulePresenting: NSObject {
    
    var featureCount: Int { get }
    func identifiresForPaymentSection(_ section: PaymentSection) -> [Int]
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectPaymentItem(at indexPath: IndexPath)
    func viewDidLoad()
    
    var view: (IPaymentFeatureModuleVC & ModuleVC)? { get set }
}

final class PaymentFeatureModulePresenter: NSObject, PaymentFeatureModulePresenting {

    private var activeFeatures: [PaymentFeature] {
        
        var features = [PaymentFeature]()
        
        if partPayService.bnplplanEnabled,
           sdkManager.payStrategy != .partPay {
            features.append(.bnpl)
        }
        return features
    }
    
    var featureCount: Int {
        
        activeFeatures.count
    }
    
    weak var view: (IPaymentFeatureModuleVC & ModuleVC)?
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
    
    func identifiresForPaymentSection(_ section: PaymentSection) -> [Int] {
        
        switch section {
        case .features:
            
            return activeFeatures.map { $0.rawValue }
        case .card:
            if let paymentId = userService.selectedCard?.cardNumber.hash {
                return [paymentId]
            } else {
                return []
            }
        }
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .card:
            cardTapped()
        case .features:
            partPayTapped()
        }
    }
    
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return nil }
        
        switch section {
        case .features:

            guard let buttonBnpl = partPayService.bnplplan?.buttonBnpl else { return nil }
            
            return PartPayModelFactory.build(indexPath,
                                             buttonBnpl: buttonBnpl,
                                             bnplplanSelected: partPayService.bnplplanSelected)
            
        case .card:
            
            guard let selectedCard = userService.selectedCard else { return nil }
            return CardModelFactory.build(indexPath,
                                          selectedCard: selectedCard,
                                          additionalCards: userService.additionalCards,
                                          cardBalanceNeed: featureToggle.isEnabled(.cardBalance),
                                          compoundWalletNeed: featureToggle.isEnabled(.compoundWallet))
        }
    }
    
    private func partPayTapped() {
        
        router.presentPartPay { [weak self] in
            self?.configViews()
            self?.view?.reloadData()
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
            
            await MainActor.run {
                self.router.presentCards(cards: user.paymentToolInfo.paymentTool,
                                         cost: finalCost?.price(.RUB) ?? "",
                                         selectedId: selectedCard.paymentID,
                                         selectedCard: { [weak self] card in
                    self?.view?.contentParrent?.hideLoading(animate: true)
                    self?.userService.selectedCard = card
                    self?.view?.reloadData()
                })
            }
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
                        
                        await MainActor.run {
                            router.presentBankAppPicker {
                                self.repeatAuth()
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
    
    private func repeatAuth() {
        Task {
            
            try await self.authService.auth()
            
            self.authService.bankCheck = true
            self.presentListCards()
        }
    }
}
