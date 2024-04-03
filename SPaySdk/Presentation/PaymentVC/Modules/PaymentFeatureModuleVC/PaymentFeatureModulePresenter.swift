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

enum PaymentFeatureSection: Int, CaseIterable {
    
    case features
}

enum PaymentFeature: Int, CaseIterable {
    case bnpl
}

protocol PaymentFeatureModulePresenting: NSObject {
    
    var featureCount: Int { get }
    func identifiresForPaymentSection(_ section: PaymentFeatureSection) -> [Int]
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
    
    func identifiresForPaymentSection(_ section: PaymentFeatureSection) -> [Int] {
        
        return activeFeatures.map { $0.rawValue }
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        partPayTapped()
    }
    
    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let buttonBnpl = partPayService.bnplplan?.buttonBnpl else { return nil }
        
        return PartPayModelFactory.build(indexPath,
                                         buttonBnpl: buttonBnpl,
                                         bnplplanSelected: partPayService.bnplplanSelected)
    }
    
    private func partPayTapped() {
        
        Task {
           await router.presentPartPay()
            configViews()
            view?.reloadData()
        }
    }
    
    private func configViews() {
        
        view?.addSnapShot()
    }
}
