//
//  MainPaymentPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.12.2023.
//

import Foundation

final class MainPaymentViewModel: PaymentViewModel {
    
    weak var presenter: PaymentPresentingInput?
    
    private let featureToggle: FeatureToggleService
    private var userService: UserService
    private var partPayService: PartPayService
    private var payAmountValidationManager: PayAmountValidationManager
    private let authManager: AuthManager
    
    private let screenEvent = [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue]
    
    private var activeFeatures: [PaymentFeature] {
        
        var features = [PaymentFeature]()
        
        if partPayService.bnplplanEnabled {
            features.append(.bnpl)
        }
        return features
    }
    
    init(userService: UserService,
         featureToggle: FeatureToggleService,
         partPayService: PartPayService,
         authManager: AuthManager,
         payAmountValidationManager: PayAmountValidationManager) {
        self.featureToggle = featureToggle
        self.userService = userService
        self.partPayService = partPayService
        self.payAmountValidationManager = payAmountValidationManager
        self.authManager = authManager
    }
    
    var purchaseInfoText: String? { nil }
    
    var levelsCount: Int {
        
        if partPayService.bnplplanSelected {
            return partPayService.bnplplan?.graphBnpl?.payments.count ?? 0
        } else {
            return 0
        }
    }
    
    var screenHeight: ScreenHeightState {
        
        if featureCount > 0 {
            return .max
        } else {
            return .normal
        }
    }
    
    var hintsText: [String] {
        addHintIfNeeded()
    }
    
    var payButton: Bool { true }
    
    var featureCount: Int { activeFeatures.count }
    
    func identifiresForSection(_ section: PaymentSection) -> [Int] {
        
        switch section {
        case .features:
            
            return activeFeatures.map { $0.rawValue }
        case .card:
            if let paymentId = userService.selectedCard?.paymentId {
                return [paymentId]
            } else {
                return []
            }
        }
    }
    
    func identifiresForPurchaseSection() -> [Int] {
        
        if partPayService.bnplplanSelected,
           let dates = partPayService.bnplplan?.graphBnpl?.payments.map({ $0.date }) {
            return dates.map { $0.hash }
        } else {
            return [.zero]
        }
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .card:
            presenter?.cardTapped()
        case .features:
            presenter?.partPayTapped()
        }
    }
    
    func model(for indexPath: IndexPath) -> AbstractCellModel? {
        
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
    
    private func addHintIfNeeded() -> [String] {
        
        guard let tool = userService.selectedCard else { return [] }
        
        var hints = [String]()
        
        if let connectHint = connectIfNeeded() {
            
            hints.append(connectHint)
        }
        
        let payAmountStatus = try? payAmountValidationManager.checkAmountSelectedTool(tool)
        
        switch payAmountStatus {
            
        case .enouth, .none:
            
            return hints
        case .onlyBnpl:
            
            hints.append(Strings.Hints.Bnpl.title)
        case .notEnouth:
            
            hints.append(Strings.Hints.NotEnouth.title)
        }
        
        return hints
    }
    
    private func connectIfNeeded() -> String? {
        
        guard let merchantInfo = authManager.authModel?.merchantInfo else { return nil }
        guard merchantInfo.bindingIsNeeded else { return nil }
        
        return merchantInfo.bindingSafeText
    }
}
