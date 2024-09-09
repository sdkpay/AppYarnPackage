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
                      selectedId: Int,
                      selectedCard: @escaping (PaymentTool) -> Void) {
        let router = moduleRouter()
        let presenter = modulePresenter(router,
                                        cards: cards,
                                        selectedId: selectedId,
                                        selectedCard: selectedCard)
        let contentView = moduleView(presenter: presenter)
        router.viewController = contentView
        presenter.view = contentView
        transition.performTransition(for: contentView)
    }
    
    private func moduleRouter() -> CardsRouter {
        CardsRouter(with: locator.resolve())
    }
    
    private func modulePresenter(_ router: CardsRouter,
                                 cards: [PaymentTool],
                                 selectedId: Int,
                                 selectedCard: @escaping (PaymentTool) -> Void) -> CardsPresenter {
        let presenter = CardsPresenter(router,
                                       userService: locator.resolve(),
                                       authManager: locator.resolve(),
                                       partPayService: locator.resolve(),
                                       analytics: locator.resolve(),
                                       cards: cards,
                                       selectedId: selectedId,
                                       featureToggle: locator.resolve(),
                                       selectedCard: selectedCard)
        return presenter
    }
    
    private func moduleView(presenter: CardsPresenter) -> ContentVC & ICardsVC {
        let view = CardsVC(presenter, analytics: locator.resolve())
        presenter.view = view
        return view
    }
}
