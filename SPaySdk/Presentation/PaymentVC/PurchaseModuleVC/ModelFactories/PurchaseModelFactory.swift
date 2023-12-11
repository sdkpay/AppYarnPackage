//
//  PurchaseModelFactory.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.12.2023.
//

import Foundation

enum PurchaseModelFactory {
    
    static func build(_ indexPath: IndexPath,
                      bnplPayment: [Payment],
                      fullPayment: OrderAmount,
                      bnplplanSelected: Bool) -> PurchaseModel {
        
        if bnplplanSelected {
            
            let currentPayment = bnplPayment[indexPath.row]
            
            let subtitle = indexPath.row == 0 ? Strings.Today.title : currentPayment.date
            
            return PurchaseModel(title: currentPayment.amount.price(.RUB),
                                 subTitle: Strings.Payment.Part.subtitile(fullPayment.amount.price(.RUB),
                                                                          subtitle))
        } else {
            return PurchaseModel(title: fullPayment.amount.price(.RUB),
                                 subTitle: nil)
        }
    }
}
