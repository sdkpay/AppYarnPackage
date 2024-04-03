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

    @MainActor 
    func createModule(transition: Transition,
                      cards: [PaymentTool],
                      cost: String,
                      selectedId: Int,
                      selectedCard: @escaping (PaymentTool) -> Void) {
        let presenter = modulePresenter(cards: cards, selectedId: selectedId, selectedCard: selectedCard)
        let contentView = moduleView(presenter: presenter, cost: cost)
        presenter.view = contentView
        transition.performTransition(for: contentView)
    }

    private func modulePresenter(cards: [PaymentTool],
                                 selectedId: Int,
                                 selectedCard: @escaping (PaymentTool) -> Void) -> CardsPresenter {
        let presenter = CardsPresenter(userService: locator.resolve(),
                                       analytics: locator.resolve(),
                                       cards: cards,
                                       selectedId: selectedId,
                                       featureToggle: locator.resolve(),
                                       timeManager: OptimizationCheсkerManager(),
                                       selectedCard: selectedCard)
        return presenter
    }
    
    private func moduleView(presenter: CardsPresenter, cost: String) -> ContentVC & ICardsVC {
        let view = CardsVC(presenter, analytics: locator.resolve(), cost: cost)
        presenter.view = view
        return view
    }
}
