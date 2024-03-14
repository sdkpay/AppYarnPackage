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
            
           // let subtitle = indexPath.row == 0 ? Strings.Localizable.Today.title : currentPayment.date
            
            if let clientCommission = currentPayment.clientCommission {
                
                return PurchaseModel(title: currentPayment.amount.price(.RUB),
                                     subTitle: Strings.Payment.Part.Commission.subtitile(fullPayment.amount.price(.RUB),
                                                                                         clientCommission.price(.RUB)))
            } else {
                
                return PurchaseModel(title: currentPayment.amount.price(.RUB),
                                     subTitle: Strings.Payment.Part.subtitile(fullPayment.amount.price(.RUB)))
            }
        } else {
            return PurchaseModel(title: fullPayment.amount.price(.RUB),
                                 subTitle: nil)
        }
    }
    
    static func build(title: String) -> PurchaseModel {
        
        PurchaseModel(title: title,
                      subTitle: nil)
    }
}
