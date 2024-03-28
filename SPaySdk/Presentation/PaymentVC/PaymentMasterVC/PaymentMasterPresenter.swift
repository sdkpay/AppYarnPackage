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
}

protocol PaymentModuleMasterPresenting {
    
    func cancelTapped()
    func viewDidLoad()
    var viewHeight: CGFloat? { get }
    var paymentsModuls: [ModuleVC] { get }
}

final class PaymentMasterPresenter: NSObject, PaymentModuleMasterPresenting {

    weak var view: (IPaymentMasterVC & ContentVC)?
    private let analytics: AnalyticsManager
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
    
    init(analytics: AnalyticsManager,
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
    
    private func setViewName() {
        
        switch mode {
        case .pay:
            view?.analyticsName = .PayView
        case .helper:
            view?.analyticsName = .HelpersView
        case .connect:
            view?.analyticsName = .PayView
        case .partPay:
            view?.analyticsName = .PayView
        }
    }
    
    func viewDidLoad() {
        setViewName()
        
        switch mode {
        case .pay, .helper, .connect:
            view?.setCancelTitle(Strings.Common.Cancel.title)
        case .partPay:
            view?.setCancelTitle(Strings.Common.Cancel.Pay.title)
        }
    }
    
    func cancelTapped() {
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: MetricsValue(rawValue: "Close"))
            .build(), on: view?.analyticsName ?? .None)
        completionManager.dismissCloseAction(view)
    }
}
