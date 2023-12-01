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
        
        return PaymentFeatureModel(iconViewURL: bnplplanSelected ? buttonBnpl.activeButtonLogo : buttonBnpl.inactiveButtonLogo,
                                   title: buttonBnpl.header,
                                   subTitle: buttonBnpl.content,
                                   switchOn: bnplplanSelected)
    }
}
