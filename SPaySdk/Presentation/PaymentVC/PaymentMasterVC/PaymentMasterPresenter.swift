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
    case partPay
}

enum PaymentModule {
    
    case merchInfoModule
    case partPayModule
    case purchaseModule
    case hintModule
    case connectInfoModule
    case helperFeatureModule
    case paymentFeatureModule
    case paymentModule
    case paymentPartPayModule
}

protocol PaymentModuleMasterPresenting {
    
    func cancelTapped()
    func viewDidAppear()
    func viewDidLoad()
    func viewDidDisappear()
    var viewHeight: CGFloat? { get }
    var paymentsModuls: [ModuleVC] { get }
}

final class PaymentMasterPresenter: NSObject, PaymentModuleMasterPresenting {

    weak var view: (IPaymentMasterVC & ContentVC)?
    private let analytics: AnalyticsService
    private let completionManager: CompletionManager
    private let mode: PaymentVCMode
    let paymentsModuls: [ModuleVC]
    
    private let helperConfig: HelperConfigManager
    private let partPayService: PartPayService
    
    var viewHeight: CGFloat? {
        
        switch mode {
        case .pay:
            
            return partPayService.bnplplanEnabled ? ScreenHeightState.big.height : ScreenHeightState.normal.height
        case .helper:
            
            if helperConfig.helperAvaliable(bannerListType: .creditCard)
                && helperConfig.helperAvaliable(bannerListType: .sbp) {
                return ScreenHeightState.big.height
            } else {
                return ScreenHeightState.normal.height
            }
        case .connect:
            
            return ScreenHeightState.normal.height
        case .partPay:
            return nil
        }
    }
    
    private let screenEvent = [AnalyticsKey.view: AnlyticsScreenEvent.PaymentVC.rawValue]
    
    init(analytics: AnalyticsService,
         submodule: [ModuleVC],
         mode: PaymentVCMode,
         helperConfig: HelperConfigManager,
         partPayService: PartPayService,
         completionManager: CompletionManager) {
        self.analytics = analytics
        self.paymentsModuls = submodule
        self.mode = mode
        self.helperConfig = helperConfig
        self.partPayService = partPayService
        self.completionManager = completionManager
        super.init()
    }
    
    func viewDidLoad() {
        view?.setCancelTitle(Strings.Cancel.title)
    }
    
    func viewDidAppear() {
        
        analytics.sendEvent(.LCPayViewAppeared, with: screenEvent)
    }
    
    func viewDidDisappear() {
        
        analytics.sendEvent(.LCPayViewDisappeared, with: screenEvent)
    }
    
    func cancelTapped() {
        completionManager.dismissCloseAction(view)
    }
}
