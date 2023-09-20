//
//  PaymentFeaturesConfig.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.05.2023.
//

import Foundation

enum PaymentFeaturesConfig {
    static func configCardModel(userService: UserService) -> PaymentCellModel {
        guard let selectedCard = userService.selectedCard else { return PaymentCellModel() }
        return PaymentCellModel(title: selectedCard.productName ?? "",
                                subtitle: selectedCard.cardNumber.card,
                                iconURL: selectedCard.cardLogoUrl,
                                needArrow: userService.additionalCards)
    }
    
    static func configPartModel(partPayService: PartPayService) -> PaymentCellModel {
        guard let buttonBnpl = partPayService.bnplplan?.buttonBnpl else { return PaymentCellModel() }
        let icon = partPayService.bnplplanSelected ? buttonBnpl.activeButtonLogo : buttonBnpl.inactiveButtonLogo
        let subtitle = (partPayService.bnplplanSelected ? buttonBnpl.content : Strings.Part.Inactive.title) ?? ""
        return PaymentCellModel(title: buttonBnpl.header ?? "",
                                subtitle: subtitle,
                                iconURL: icon,
                                needArrow: true)
    }
}
