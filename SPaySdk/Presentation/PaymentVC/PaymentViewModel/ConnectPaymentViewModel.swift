//
//  ConnectPaymentViewModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 12.12.2023.
//

import Foundation

final class ConnectPaymentViewModel: PaymentViewModel {
        
    weak var presenter: PaymentPresentingInput?
    
    private let featureToggle: FeatureToggleService
    private var userService: UserService
    private let authManager: AuthManager
    
    init(userService: UserService,
         authManager: AuthManager,
         featureToggle: FeatureToggleService) {
        self.featureToggle = featureToggle
        self.userService = userService
        self.authManager = authManager
    }
    
    var levelsCount: Int { 0 }
    
    var screenHeight: ScreenHeightState {
        .normal
    }
    
    var purchaseInfoText: String? {
        
        ConfigGlobal.localization?.connectTitle
    }
    
    var hintsText: [String] {
        addHintIfNeeded()
    }
    
    var payButton: Bool { true }
    
    var featureCount: Int { 0 }
    
    func identifiresForSection(_ section: PaymentSection) -> [Int] {
        
        switch section {
        case .features:
            
            return []
        case .card:
            if let paymentId = userService.selectedCard?.paymentId {
                return [paymentId]
            } else {
                return []
            }
        }
    }
    
    func identifiresForPurchaseSection() -> [Int] {
        
        [.zero]
    }
    
    func model(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return nil }
        
        switch section {
        case .features:

            return nil
            
        case .card:
            
            guard let selectedCard = userService.selectedCard else { return nil }
            return CardModelFactory.build(indexPath,
                                          selectedCard: selectedCard,
                                          additionalCards: userService.additionalCards,
                                          cardBalanceNeed: featureToggle.isEnabled(.cardBalance),
                                          compoundWalletNeed: featureToggle.isEnabled(.compoundWallet))
        }
    }
    
    func didSelectPaymentItem(at indexPath: IndexPath) {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .features:

            return
            
        case .card:
            
            presenter?.cardTapped()
        }
    }
    
    private func addHintIfNeeded() -> [String] {
        
        guard let merchantInfo = authManager.authModel?.merchantInfo else { return [] }
        guard merchantInfo.bindingIsNeeded else { return [] }
        guard let bindingSafeText = merchantInfo.bindingSafeText else { return [] }
        
        return [bindingSafeText]
    }
}
