//
//  PartPayModelFactory.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 13.11.2023.
//

import Foundation

enum PartPayModelFactory {
    
    static func build(_ indexPath: IndexPath,
                      buttonBnpl: ButtonBnpl,
                      bnplplanSelected: Bool) -> PaymentFeatureModel {
        
        switch bnplplanSelected {
        case true:
            return PaymentFeatureModel(iconViewURL: buttonBnpl.activeButtonLogo,
                                       title: buttonBnpl.header,
                                       subTitle: buttonBnpl.content,
                                       switchOn: bnplplanSelected)
        case false:
            return  PaymentFeatureModel(iconViewURL: buttonBnpl.inactiveButtonLogo,
                                        title: buttonBnpl.header,
                                        subTitle: buttonBnpl.content,
                                        switchOn: bnplplanSelected)
        }
    }
}
