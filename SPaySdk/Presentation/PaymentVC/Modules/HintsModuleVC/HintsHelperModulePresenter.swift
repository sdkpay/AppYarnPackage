//
//  HintsHelperModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import UIKit
import Combine

final class HintsHelperModulePresenter: NSObject, HintsModulePresenting {
    
    weak var view: (IHintsModuleVC & ModuleVC)?
    private var payAmountValidationManager: PayAmountValidationManager
    private let helperConfigManager: HelperConfigManager
    private var cancellable = Set<AnyCancellable>()
    private var partPayService: PartPayService
    
    init(helperConfigManager: HelperConfigManager,
         partPayService: PartPayService,
         payAmountValidationManager: PayAmountValidationManager) {
        self.helperConfigManager = helperConfigManager
        self.partPayService = partPayService
        self.payAmountValidationManager = payAmountValidationManager
        super.init()
    }
    
    func viewDidLoad() {
        setHints()
    }
    
    private func setHints() {
        
        view?.setHints(with: hintsText)
    }
    
    var hintsText: [String] {

        let avaliableBunners = avaliableBunners()
        
        if avaliableBunners.count > 1 {
            return [Strings.Hints.All.title]
        }
        
        if avaliableBunners.first == .sbp {
            return [Strings.Hints.Sbp.title]
        }
        
        if avaliableBunners.first == .credit {
            return [Strings.Hints.Credit.title]
        }
        
        if avaliableBunners.first == .bnpl {
            return [Strings.Hints.Bnpl.title]
        }
        
        return []
    }
    
    private func avaliableBunners() -> [HelperType] {
        
        var list = [HelperType]()
        
        if helperConfigManager.helperAvaliable(bannerListType: .sbp) {
            list.append(.sbp)
        }
        
        if helperConfigManager.helperAvaliable(bannerListType: .creditCard) {
            list.append(.credit)
        }
        
        if partPayService.bnplplanEnabled {
            list.append(.bnpl)
        }
        
        return list
    }
}
