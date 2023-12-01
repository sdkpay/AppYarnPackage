//
//  CardModelFactory.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 13.11.2023.
//

import Foundation

enum CardModelFactory {
    
    static func build(_ indexPath: IndexPath,
                      selectedCard: PaymentToolInfo,
                      additionalCards: Bool,
                      cardBalanceNeed: Bool,
                      compoundWalletNeed: Bool) -> CardModel {
        
        var title: String
        var subtitle: String
        
        if cardBalanceNeed {
            
            title = selectedCard.amountData.amountInt.price(.RUB)
            subtitle = "\(selectedCard.productName ?? "none") \(selectedCard.cardNumber.card)"
        } else {
            
            title = selectedCard.productName ?? "none"
            subtitle = selectedCard.cardNumber.card
        }
        
        if let count = selectedCard.countAdditionalCards, compoundWalletNeed {
            subtitle += Strings.Payment.Cards.CompoundWallet.title(String(count).addEnding(ends: [
                "1": Strings.Payment.Cards.CompoundWallet.one,
                "234": Strings.Payment.Cards.CompoundWallet.two,
                "567890": Strings.Payment.Cards.CompoundWallet.two
            ]))
        }

        return CardModel(iconViewURL: selectedCard.cardLogoUrl,
                         title: title,
                         subTitle: subtitle,
                         needArrow: additionalCards)
    }
}
