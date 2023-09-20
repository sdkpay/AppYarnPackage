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
    private let screenEvent = "screen: \(AnlyticsScreenEvent.CardsVC.rawValue)"

    init(userService: UserService,
         analytics: AnalyticsService,
         cards: [PaymentToolInfo],
         selectedId: Int,
         timeManager: OptimizationCheсkerManager,
         selectedCard: @escaping (PaymentToolInfo) -> Void) {
        self.analytics = analytics
        self.userService = userService
        self.cards = cards
        self.selectedCard = selectedCard
        self.selectedId = selectedId
        self.timeManager = timeManager
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        configViews()
        timeManager.endTraking(CardsVC.self.description()) { _  in
//            analytics.sendEvent(.CardsViewAppeared, with: [$0])
        }
    }

    func model(for indexPath: IndexPath) -> CardCellModel {
        let card = cards[indexPath.row]
        return CardCellModel(title: card.productName ?? "",
                             number: card.cardNumber.card,
                             selected: card.paymentId == selectedId,
                             cardURL: card.cardLogoUrl)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        analytics.sendEvent(.TouchCard, with: screenEvent)
        selectedCard(cards[indexPath.row])
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    func viewDidAppear() {
        analytics.sendEvent(.LCPayViewAppeared, with: screenEvent)
    }
    
    func viewDidDisappear() {
        analytics.sendEvent(.LCPayViewDisappeared, with: screenEvent)
    }

    private func configViews() {
        guard let user = userService.user else { return }
        view?.configProfileView(with: user.userInfo)
    }
}
