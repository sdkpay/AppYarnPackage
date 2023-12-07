//
//  HelperModelFactory.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.12.2023.
//

import Foundation

enum HelperModelFactory {
    
    static func build(_ indexPath: IndexPath,
                      value: BannerList) -> PaymentFeatureModel {
        
        return PaymentFeatureModel(iconViewURL: value.iconUrl,
                                   title: value.title,
                                   subTitle: value.text,
                                   switchOn: false,
                                   switchNeed: false)
    }
}
