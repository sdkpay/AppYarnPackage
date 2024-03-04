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
    
    init(helperConfigManager: HelperConfigManager,
         payAmountValidationManager: PayAmountValidationManager) {
        self.helperConfigManager = helperConfigManager
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
        
        if  avaliableBunners.first == .creditCard {
            return [Strings.Hints.Credit.title]
        }
        
        return []
    }
    
    private func avaliableBunners() -> [BannerListType] {
        
        var list = [BannerListType]()
        
        if helperConfigManager.helperAvaliable(bannerListType: .sbp) {
            list.append(.sbp)
        }
        
        if helperConfigManager.helperAvaliable(bannerListType: .creditCard) {
            list.append(.creditCard)
        }
        
        return list
    }
}
