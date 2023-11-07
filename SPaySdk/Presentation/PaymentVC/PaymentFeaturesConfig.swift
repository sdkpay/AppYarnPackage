//
//  PaymentFeaturesConfig.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.05.2023.
//

import Foundation

enum PaymentFeaturesConfig {
    static func configCardModel(userService: UserService,
                                featureToggle: FeatureToggleService) -> PaymentCellModel {
        guard let selectedCard = userService.selectedCard else { return PaymentCellModel() }
        var subtitle = selectedCard.cardNumber.card
        
        if let count = selectedCard.countAdditionalCards, featureToggle.isEnabled(.compoundWallet) {
            subtitle += Strings.Payment.Cards.CompoundWallet.title(String(count).addEnding(ends: [
                "1": Strings.Payment.Cards.CompoundWallet.one,
                "234": Strings.Payment.Cards.CompoundWallet.two,
                "567890": Strings.Payment.Cards.CompoundWallet.two
            ]))
        }
        
        return PaymentCellModel(title: selectedCard.productName ?? "",
                                subtitle: subtitle,
                                iconURL: selectedCard.cardLogoUrl,
                                needArrow: userService.additionalCards)
    }
    
    static func configPartModel(partPayService: PartPayService) -> PaymentCellModel {
        guard let buttonBnpl = partPayService.bnplplan?.buttonBnpl else { return PaymentCellModel() }
        let icon = partPayService.bnplplanSelected ? buttonBnpl.activeButtonLogo : buttonBnpl.inactiveButtonLogo
        let subtitle = buttonBnpl.content ?? ""
        return PaymentCellModel(title: buttonBnpl.header ?? "",
                                subtitle: subtitle,
                                iconURL: icon,
                                needArrow: true)
    }
}
