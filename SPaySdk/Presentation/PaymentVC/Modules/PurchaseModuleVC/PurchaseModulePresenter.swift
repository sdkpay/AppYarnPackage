//
//  PurchaseModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.03.2024.
//

import Foundation
import UIKit
import Combine

enum PurchaseSection: Int, CaseIterable {
    case all
}

protocol PurchaseModulePresenting: NSObject {
    
    var levelsCount: Int { get }
    func identifiresForPurchaseSection() -> [Int]
    func purchaseModel(for indexPath: IndexPath) -> AbstractCellModel?
    func viewDidLoad()
    
    var view: (IPurchaseModuleVC & ModuleVC)? { get set }
}

final class PurchaseModulePresenter: NSObject, PurchaseModulePresenting {
    
    private var activeFeatures = [PaymentFeature]()
    
    var featureCount: Int { activeFeatures.count }
    
    var levelsCount: Int {
        partPayService.bnplplan?.graphBnpl?.payments.count ?? 0
    }
    
    weak var view: (IPurchaseModuleVC & ModuleVC)?
    private let router: PaymentRouting
    private let partPayService: PartPayService
    private let userService: UserService
    private let payAmountValidationManager: PayAmountValidationManager
    private var cancellable = Set<AnyCancellable>()
    
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
        showPartsViewifNeed()
        addSubscribers()
        configBonusesView()
    }
    
    private func addSubscribers() {
        
        partPayService.bnplplanSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.configViews()
                self.showPartsViewifNeed()
            }
            .store(in: &cancellable)
        userService.selectedCardPublisher
            .receive(on: DispatchQueue.main)
            .sink { card in
                self.configBonusesView()
            }
            .store(in: &cancellable)
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
    
    private func configBonusesView() {
        view?.configBonusesView(userService.selectedCard?.precalculateBonuses)
    }
    
    private func showPartsViewifNeed() {
        
        view?.showPartsView(partPayService.bnplplanSelected)
    }
    
    private func configViews() {
        view?.addSnapShot()
    }
}
