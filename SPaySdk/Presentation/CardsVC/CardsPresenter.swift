//
//  CardsPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

protocol CardsPresenting {
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    var cardsCount: Int { get }
    func model(for indexPath: IndexPath) -> CardCellModel
    func didSelectRow(at indexPath: IndexPath)
}

final class CardsPresenter: CardsPresenting {
    
    weak var view: (ICardsVC & ContentVC)?
    
    var cardsCount: Int {
        cards.count
    }

    private let analytics: AnalyticsService
    private let userService: UserService
    private let cards: [PaymentToolInfo]
    private let selectedCard: (PaymentToolInfo) -> Void
    private let selectedId: Int
    private var timeManager: OptimizationCheсkerManager
    private let screenEvent = [AnalyticsKey.view: AnlyticsScreenEvent.CardsVC.rawValue]
    private var featureToggle: FeatureToggleService

    init(userService: UserService,
         analytics: AnalyticsService,
         cards: [PaymentToolInfo],
         selectedId: Int,
         featureToggle: FeatureToggleService,
         timeManager: OptimizationCheсkerManager,
         selectedCard: @escaping (PaymentToolInfo) -> Void) {
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
            
            title = card.amountData.amountInt.price(.RUB)
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
        
        return CardCellModel(title: title,
                             subtitle: subtitle,
                             selected: card.paymentId == selectedId,
                             cardURL: card.cardLogoUrl)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        analytics.sendEvent(.TouchCard, with: screenEvent)
        selectedCard(cards[indexPath.row])
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: true)
        }
    }
    
    func viewDidAppear() {
        analytics.sendEvent(.LCPayViewAppeared, with: screenEvent)
    }
    
    func viewDidDisappear() {
        analytics.sendEvent(.LCPayViewDisappeared, with: screenEvent)
    }
}
