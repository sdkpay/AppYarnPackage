//
//  PartPayPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

struct PartCellModel {
    let title: String
    let cost: String
    let isSelected: Bool
    let hideLine: Bool
}

protocol PartPayPresenting {
    func viewDidLoad()
    var partsCount: Int { get }
    func model(for indexPath: IndexPath) -> PartCellModel
}

final class PartPayPresenter: PartPayPresenting {
    private let timeManager: OptimizationCheсkerManager
    private let analytics: AnalyticsService

    weak var view: (IPartPayVC & ContentVC)?
    
    private var payParts: [PartCellModel]
    
    var partsCount: Int {
        payParts.count
    }

    init(timeManager: OptimizationCheсkerManager,
         analytics: AnalyticsService,
         selectedCard: @escaping (PaymentToolInfo) -> Void) {
        self.analytics = analytics
        self.timeManager = timeManager
        self.timeManager.startTraking()
        let model1 = PartCellModel(title: "Оплатите сейчас",
                                   cost: 2000.price(with: 643),
                                   isSelected: true,
                                   hideLine: false)
        let model2 = PartCellModel(title: "Оплатите завтра",
                                   cost: 2000.price(with: 643),
                                   isSelected: false,
                                   hideLine: false)
        let model3 = PartCellModel(title: "Оплатите завтра",
                                   cost: 2000.price(with: 643),
                                   isSelected: false,
                                   hideLine: false)
        let model4 = PartCellModel(title: "Оплатите завтра",
                                   cost: 2000.price(with: 643),
                                   isSelected: false,
                                   hideLine: true)
        payParts = [model1, model2, model3, model4]
    }
    
    func viewDidLoad() {
        timeManager.endTraking(CardsVC.self.description()) {
            analytics.sendEvent(.CardsViewAppeared, with: [$0])
        }
        view?.setFinalCost(1600000.price(with: 643))
    }
    
    func model(for indexPath: IndexPath) -> PartCellModel {
        // DEBUG
        return payParts[indexPath.row]
    }
}
