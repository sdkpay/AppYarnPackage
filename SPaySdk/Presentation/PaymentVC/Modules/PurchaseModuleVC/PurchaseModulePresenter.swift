//
//  PurchaseModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.03.2024.
//

import Foundation
import UIKit

enum PurchaseSection: Int, CaseIterable {
    case all
}

protocol PurchaseModulePresenting: NSObject {
    
    var levelsCount: Int { get }
    func identifiresForPurchaseSection() -> [Int]
    func purchaseModel(for indexPath: IndexPath) -> AbstractCellModel?
    func profileTapped()
    func viewDidLoad()
}


final class PayPurchaseModulePresenter: NSObject, PurchaseModulePresenting {
    
    private var activeFeatures = [PaymentFeature]()
    
    var featureCount: Int { activeFeatures.count }
    
    var levelsCount: Int {
        
        if partPayService.bnplplanSelected {
            return partPayService.bnplplan?.graphBnpl?.payments.count ?? 0
        } else {
            return 0
        }
    }
    
    weak var view: (IPaymentMasterVC & ContentVC)?
    private let router: PaymentRouting
    private let partPayService: PartPayService
    private let userService: UserService
    private let payAmountValidationManager: PayAmountValidationManager
    
    init(_ router: PaymentRouting,
         manager: SDKManager,
         userService: UserService,
         partPayService: PartPayService,
         payAmountValidationManager: PayAmountValidationManager) {
        self.router = router
        self.partPayService = partPayService
        self.userService = userService
        self.payAmountValidationManager = payAmountValidationManager
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
        setHints()
    }
    
    private func setHints() {
        
        view?.setHints(with: addHintIfNeeded())
    }

    func identifiresForPurchaseSection() -> [Int] {
        
        if partPayService.bnplplanSelected,
           let dates = partPayService.bnplplan?.graphBnpl?.payments.map({ $0.date }) {
            return dates.map { $0.hash }
        } else {
            return [.zero]
        }
    }

    func purchaseModel(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let orderAmount = userService.user?.orderInfo.orderAmount else { return nil }
        
        return PurchaseModelFactory.build(indexPath,
                                          bnplPayment: partPayService.bnplplan?.graphBnpl?.payments ?? [],
                                          fullPayment: orderAmount,
                                          bnplplanSelected: partPayService.bnplplanSelected)
    }
    
    private func showPartsViewifNeed() {
        
        view?.showPartsView(partPayService.bnplplanSelected)
    }
    
    func profileTapped() {
        
        guard let user = userService.user else { return }
        router.openProfile(with: user.userInfo)
    }
    
    private func configViews() {
        
        guard let user = userService.user else { return }
        
        view?.configShopInfo(with: user.merchantInfo.merchantName,
                             iconURL: user.merchantInfo.logoURL,
                             purchaseInfoText: nil)
        view?.addSnapShot()
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
        
        guard let merchantInfo = userService.user?.merchantInfo else { return nil }
        guard merchantInfo.bindingIsNeeded else { return nil }
        
        return merchantInfo.bindingSafeText
    }
}

