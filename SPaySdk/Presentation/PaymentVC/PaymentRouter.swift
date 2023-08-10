//
//  PaymentRouter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol PaymentRouting {
    func presentCards(cards: [PaymentToolInfo],
                      selectedId: Int,
                      selectedCard: @escaping (PaymentToolInfo) -> Void)
    func presentPartPay(partPaySelected: @escaping Action)
    func presentOTPScreen(completion: @escaping Action)
}

final class PaymentRouter: PaymentRouting {
    weak var viewController: ContentVC?
    private let locator: LocatorService
    
    init(with locator: LocatorService) {
        self.locator = locator
    }
    
    func presentCards(cards: [PaymentToolInfo],
                      selectedId: Int,
                      selectedCard: @escaping (PaymentToolInfo) -> Void) {
        let vc = CardsAssembly(locator: locator).createModule(cards: cards,
                                                              selectedId: selectedId,
                                                              selectedCard: selectedCard)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
    
    func presentPartPay(partPaySelected: @escaping Action) {
        let vc = PartPayAssembly(locator: locator).createModule(partPaySelected: partPaySelected)
        viewController?.contentNavigationController?.pushViewController(vc, animated: true)
    }
    
    func presentOTPScreen(completion: @escaping Action) {
        DispatchQueue.main.async {
            let vc = OtpAssembly(locator: self.locator).createModule(completion: completion)
            self.viewController?.contentNavigationController?.pushViewController(vc, animated: true)
        }
    }
}
