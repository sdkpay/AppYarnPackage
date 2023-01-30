//
//  PaymentRouter.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol PaymentRouting {
    func presentCards(cards: [PaymentToolInfo], selectedId: Int, selectedCard: @escaping (PaymentToolInfo) -> Void)
}

final class PaymentRouter: PaymentRouting {
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    func presentCards(cards: [PaymentToolInfo], selectedId: Int, selectedCard: @escaping (PaymentToolInfo) -> Void) {
        let vc = CardsAssembly(locator: locator).createModule(cards: cards,
                                                              selectedId: selectedId,
                                                              selectedCard: selectedCard)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
