//
//  CardsPresenter.swift
//  SberPaySDK
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
    private let analytics: AnalyticsService
    private let userService: UserService
    private let cards: [PaymentToolInfo]
    private let selectedCard: (PaymentToolInfo) -> Void
    private let selectedId: Int

    weak var view: (ICardsVC & ContentVC)?
    
    var cardsCount: Int {
        cards.count
    }

    init(userService: UserService,
         analytics: AnalyticsService,
         cards: [PaymentToolInfo],
         selectedId: Int,
         selectedCard: @escaping (PaymentToolInfo) -> Void) {
        self.analytics = analytics
        self.userService = userService
        self.cards = cards
        self.selectedCard = selectedCard
        self.selectedId = selectedId
    }
    
    func viewDidLoad() {
        configViews()
        analytics.sendEvent(.CardsViewAppeared)
    }

    func model(for indexPath: IndexPath) -> CardCellModel {
        let card = cards[indexPath.row]
        return CardCellModel(title: card.productName,
                             number: card.cardNumber.card,
                             selected: card.paymentId == selectedId)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        selectedCard(cards[indexPath.row])
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    private func configViews() {
        guard let user = userService.user else { return }
        view?.configProfileView(with: user.userInfo)
    }
}
