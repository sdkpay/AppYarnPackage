//
//  CardsPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit
import Combine

protocol CardsPresenting {
    func viewDidLoad()
    var enougthCardsCount: Int { get }
    var notEnougthCardsCount: Int { get }
    var sectionsCount: Int { get }
    func model(for indexPath: IndexPath) -> CardCellModel
    func didSelectRow(at indexPath: IndexPath)
}

final class CardsPresenter: CardsPresenting {
    
    weak var view: (ICardsVC & ContentVC)?
    
    var enougthCardsCount: Int {
        enoughtCards.count
    }
    
    var notEnougthCardsCount: Int {
        notEnoughtCards.count
    }
    
    var sectionsCount: Int {
        enoughtCards = []
        notEnoughtCards = []
        
        let cost = partPayService.bnplplanSelected 
        ? partPayService.bnplplan?.graphBnpl?.parts.first?.amount
        : userService.user?.orderInfo.orderAmount.amount
        
        view?.setCostUI(cost ?? 0)
        cards.forEach { if $0.amountData.amount >= cost ?? 0 {
            enoughtCards.append($0)
        } else {
            notEnoughtCards.append($0)
        }}
        sortCards(cards: &enoughtCards)
        sortCards(cards: &notEnoughtCards)
        return notEnoughtCards.isEmpty ? 1 : 2
    }

    private let router: CardsRouting
    private let analytics: AnalyticsManager
    private let userService: UserService
    private let partPayService: PartPayService
    private var cards: [PaymentTool]
    private var enoughtCards: [PaymentTool] = []
    private var notEnoughtCards: [PaymentTool] = []
    private let selectedCard: (PaymentTool) -> Void
    private let selectedId: Int
    private var timeManager: OptimizationCheсkerManager
    private var featureToggle: FeatureToggleService
    
    private var cancellable = Set<AnyCancellable>()
    
    init(_ router: CardsRouting,
         userService: UserService,
         partPayService: PartPayService,
         analytics: AnalyticsManager,
         cards: [PaymentTool],
         selectedId: Int,
         featureToggle: FeatureToggleService,
         timeManager: OptimizationCheсkerManager,
         selectedCard: @escaping (PaymentTool) -> Void) {
        self.router = router
        self.analytics = analytics
        self.userService = userService
        self.partPayService = partPayService
        self.cards = cards
        self.selectedCard = selectedCard
        self.selectedId = selectedId
        self.featureToggle = featureToggle
        self.timeManager = timeManager
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        setupBinding()
    }
    
    private func setupBinding() {
        
        userService.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let value {
                    if value.paymentToolInfo.paymentTool.isEmpty {
                        self?.presentHelper()
                    } else {
                        self?.cards = value.paymentToolInfo.paymentTool
                        self?.view?.reloadTableView()
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    private func presentHelper() {
        Task {
            await router.presentHelper()
        }
    }

    func model(for indexPath: IndexPath) -> CardCellModel {
        let card = indexPath.section == 0 ? enoughtCards[indexPath.row] : notEnoughtCards[indexPath.row]
        
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
        let bonusesEnabled = featureToggle.isEnabled(.spasiboBonuses) && !partPayService.bnplplanSelected
        let bonuses = bonusesEnabled ? card.precalculateBonuses : nil
        
        return CardCellModel(title: title,
                             subtitle: subtitle,
                             selected: card.paymentID == selectedId,
                             bonuses: bonuses,
                             cardURL: card.cardLogoURL,
                             isEnoughtMoney: indexPath.section == 0)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: .card)
            .build(), on: view?.analyticsName ?? .None)
        selectedCard(cards[indexPath.row])
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: true)
        }
    }
    
    private func sortCards(cards: inout [PaymentTool]) {
        
        cards = cards
            .sorted(by: { ($0.amountData.amount > $1.amountData.amount) })
            .sorted(by: { $0.priorityCard && !$1.priorityCard })
    }
}
