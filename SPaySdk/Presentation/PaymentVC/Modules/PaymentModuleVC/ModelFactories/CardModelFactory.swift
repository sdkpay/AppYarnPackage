//
//  CardModelFactory.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 13.11.2023.
//

import Foundation

enum CardModelFactory {
    
    static func build(_ indexPath: IndexPath,
                      selectedCard: PaymentTool,
                      additionalCards: Bool,
                      cardBalanceNeed: Bool,
                      compoundWalletNeed: Bool) -> CardModel {
        
        var title: String
        var subtitle: String
        
        if cardBalanceNeed {
            
            title = selectedCard.amountData.amount.price(.RUB)
            subtitle = "\(selectedCard.productName) \(selectedCard.cardNumber.card)"
        } else {
            
            title = selectedCard.productName
            subtitle = selectedCard.cardNumber.card
        }
        
        if let count = selectedCard.countAdditionalCards, compoundWalletNeed {
            subtitle += Strings.Payment.Cards.CompoundWallet.title(String(count))
        }

        return CardModel(iconViewURL: selectedCard.cardLogoURL,
                         title: title,
                         subTitle: subtitle,
                         needArrow: additionalCards)
    }
}
