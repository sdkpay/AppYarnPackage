//
//  PaymentPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import Foundation
import UIKit

enum PaymentVCMode {
    case pay
    case helper
    case connect
}

enum PurchaseSection: Int, CaseIterable {
    case all
}
//
//protocol PaymentMasterPresenting: NSObject {
//    
//    var featureCount: Int { get }
//    var levelsCount: Int { get }
//    var purchaseInfoText: String? { get }
//    var screenHeight: ScreenHeightState { get }
//    func identifiresForPaymentSection(_ section: PaymentSection) -> [Int]
//    func identifiresForPurchaseSection() -> [Int]
//    func paymentModel(for indexPath: IndexPath) -> AbstractCellModel?
//    func purchaseModel(for indexPath: IndexPath) -> AbstractCellModel?
//    func didSelectPaymentItem(at indexPath: IndexPath)
//    func viewDidLoad()
//    func payButtonTapped()
//    func cancelTapped()
//    func viewDidAppear()
//    func viewDidDisappear()
//    var payButtonText: String? { get }
//}

protocol PurchaseModuleMasterPresenting {
    
    func openProfile()
}

protocol PaymentModuleMasterPresenting {
    
    func openProfile()
}

protocol PaymentMasterPresenting {
    
  func reload()
}

final class PaymentMasterPresenter: NSObject, PurchaseModuleMasterPresenting, PaymentMasterPresenting, PurchaseModuleMasterPresenting {
    
    weak var view: (IPaymentMasterVC & ContentVC)?
    private let router: PaymentRouting
    private let analytics: AnalyticsService
    
    private let screenEvent = [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue]
    
    init(_ router: PaymentRouting,
         analytics: AnalyticsService) {
        self.router = router
        self.analytics = analytics
        super.init()
    }
    
    func viewDidLoad() {
    }
    
    func viewDidAppear() {
        
        analytics.sendEvent(.LCPayViewAppeared, with: screenEvent)
    }
    
    func viewDidDisappear() {
        
        analytics.sendEvent(.LCPayViewDisappeared, with: screenEvent)
    }
}
