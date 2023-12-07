//
//  PaymentViewHelpModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.12.2023.
//

import Foundation

final class PaymentViewHelpModel: PaymentViewModel {

    private let featureToggle: FeatureToggleService
    private var userService: UserService
    private let helperConfigManager: HelperConfigManager
    
    private var activeFeatures: [BannerList] {
        configBanners()
    }

    init(userService: UserService,
         featureToggle: FeatureToggleService, 
         helperConfigManager: HelperConfigManager) {
        self.featureToggle = featureToggle
        self.helperConfigManager = helperConfigManager
        self.userService = userService
    }

    var needHint: Bool { true }
    
    var hintText: String {
        
        let avaliableBunners = avaliableBunners()
        
        if avaliableBunners.count > 1 {
            return Strings.Hints.All.title
        }
        
        if avaliableBunners.first == .sbp {
            return Strings.Hints.Sbp.title
        }
        
        if  avaliableBunners.first == .creditCard {
            return Strings.Hints.Credit.title
        }
        
        return ""
    }
    
    var payButton: Bool { false }
    
    var featureCount: Int { activeFeatures.count }
    
    func identifiresForSection(_ section: PaymentSection) -> [Int] {
        
        switch section {
        case .features:
            return activeFeatures.compactMap({ $0.hashValue })
        case .card:
            return []
        }
    }
    
    func model(for indexPath: IndexPath) -> AbstractCellModel? {
        
        guard let section = PaymentSection(rawValue: indexPath.section) else { return nil }
        
        switch section {
        case .features:
            
            let helper = activeFeatures[indexPath.row]
            
            return HelperModelFactory.build(indexPath, value: helper)
            
        case .card:
            
            return nil
        }
    }
    
    private func configBanners() -> [BannerList] {

        guard let user = userService.user else { return [] }
        
        let avaliableBunners = avaliableBunners()
        
        return user.promoInfo.bannerList.filter { list in
            avaliableBunners.contains(list.bannerListType)
        }
    }
    
    private func avaliableBunners() -> [BannerListType] {
        
        var list = [BannerListType]()
        
        if helperConfigManager.config.sbp, featureToggle.isEnabled(.sbp) {
            list.append(.sbp)
        }
         
        if helperConfigManager.config.creditCard, featureToggle.isEnabled(.newCreditCard) {
            list.append(.creditCard)
        }
        
        return list
    }
}
