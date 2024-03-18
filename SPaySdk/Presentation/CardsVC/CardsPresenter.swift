//
//  CardsPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

protocol CardsPresenting {
    func viewDidLoad()
    var cardsCount: Int { get }
    func model(for indexPath: IndexPath) -> CardCellModel
    func didSelectRow(at indexPath: IndexPath)
}

final class CardsPresenter: CardsPresenting {
    
    weak var view: (ICardsVC & ContentVC)?
    
    var cardsCount: Int {
        cards.count
    }

    private let analytics: AnalyticsManager
    private let userService: UserService
    private let cards: [PaymentTool]
    private let selectedCard: (PaymentTool) -> Void
    private let selectedId: Int
    private var timeManager: OptimizationCheсkerManager
    private var featureToggle: FeatureToggleService

    init(userService: UserService,
         analytics: AnalyticsManager,
         cards: [PaymentTool],
         selectedId: Int,
         featureToggle: FeatureToggleService,
         timeManager: OptimizationCheсkerManager,
         selectedCard: @escaping (PaymentTool) -> Void) {
        self.analytics = analytics
        self.userService = userService
        self.cards = cards
        self.selectedCard = selectedCard
        self.selectedId = selectedId
        self.featureToggle = featureToggle
        self.timeManager = timeManager
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {}

    func model(for indexPath: IndexPath) -> CardCellModel {
        let card = cards[indexPath.row]
        
        var title: String
        var subtitle: String
        
        if featureToggle.isEnabled(.cardBalance) {
            
            title = card.amountData.amount.price(.RUB)
            subtitle = "\(card.productName) \(card.cardNumber.card)"
        } else {
            
            title = card.productName
            subtitle = card.cardNumber.card
        }
        
        if let count = card.countAdditionalCards, featureToggle.isEnabled(.compoundWallet) {
            subtitle += Strings.Payment.Cards.CompoundWallet.title(String(count).addEnding(ends: [
                "1": Strings.Payment.Cards.CompoundWallet.one,
                "234": Strings.Payment.Cards.CompoundWallet.two,
                "567890": Strings.Payment.Cards.CompoundWallet.two
            ]))
        }
        let bonuses = featureToggle.isEnabled(.spasiboBonuses) ? card.precalculateBonuses : nil
        return CardCellModel(title: title,
                             subtitle: subtitle,
                             selected: card.paymentID == selectedId,
                             bonuses: bonuses,
                             cardURL: card.cardLogoURL)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: "Card")
            .build(), on: view?.analyticsName ?? .None)
        selectedCard(cards[indexPath.row])
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: true)
        }
    }
}
