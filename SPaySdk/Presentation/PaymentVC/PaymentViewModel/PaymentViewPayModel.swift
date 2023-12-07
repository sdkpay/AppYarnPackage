//
//  PaymentViewPayModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.12.2023.
//

import Foundation

final class PaymentViewPayModel: PaymentViewModel {
    
    private let featureToggle: FeatureToggleService
    private var userService: UserService
    private var partPayService: PartPayService
    private var payAmountValidationManager: PayAmountValidationManager
    
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
         payAmountValidationManager: PayAmountValidationManager) {
        self.featureToggle = featureToggle
        self.userService = userService
        self.partPayService = partPayService
        self.payAmountValidationManager = payAmountValidationManager
    }
    
    var needHint: Bool {
        addHintIfNeeded() != nil
    }
    
    var hintText: String {
        addHintIfNeeded() ?? ""
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
    
    private func addHintIfNeeded() -> String? {
        
        guard let tool = userService.selectedCard else { return nil }
        
       let payAmountStatus = try? payAmountValidationManager.checkAmountSelectedTool(tool)
        
        switch payAmountStatus {
        case .enouth:
            return nil
        case .onlyBnpl:
            return Strings.Hints.Bnpl.title
        case .notEnouth:
            return Strings.Hints.NotEnouth.title
        case .none:
            return nil
        }
    }
}
