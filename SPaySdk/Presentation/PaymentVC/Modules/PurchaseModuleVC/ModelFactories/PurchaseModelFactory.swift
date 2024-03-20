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
            
            let subtitle = Strings.Payment.Part.subtitile(fullPayment.amount.price(.RUB))
            
            if let clientCommission = currentPayment.clientCommission, indexPath.row == 0 {
                
                return PurchaseModel(title: currentPayment.amount.price(.RUB),
                                     subTitle: subtitle + Strings.Payment.Part.Commission.subtitile(clientCommission.price()))
            } else {
                
                let datePart = indexPath.row == 0 ? Strings.Payment.Part.Subtitile.Date.First.subtitile : currentPayment.date
                return PurchaseModel(title: currentPayment.amount.price(.RUB),
                                     subTitle: subtitle + Strings.Payment.Part.Subtitile.Date.subtitile(datePart))
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
