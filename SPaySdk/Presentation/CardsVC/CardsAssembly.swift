//
//  CardsAssembly.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

final class CardsAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(cards: [PaymentToolInfo],
                      selectedId: Int,
                      selectedCard: @escaping (PaymentToolInfo) -> Void) -> ContentVC {
        let presenter = modulePresenter(cards: cards, selectedId: selectedId, selectedCard: selectedCard)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(cards: [PaymentToolInfo],
                                 selectedId: Int,
                                 selectedCard: @escaping (PaymentToolInfo) -> Void) -> CardsPresenter {
        let presenter = CardsPresenter(userService: locator.resolve(),
                                       analytics: locator.resolve(),
                                       cards: cards,
                                       selectedId: selectedId,
                                       timeManager: OptimizationCheсkerManager(),
                                       selectedCard: selectedCard)
        return presenter
    }
    
    private func moduleView(presenter: CardsPresenter) -> ContentVC & ICardsVC {
        let view = CardsVC(presenter)
        presenter.view = view
        return view
    }
}
