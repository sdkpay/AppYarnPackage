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
    func checkTapped(_ value: Bool)
    func agreementViewTapped()
    func acceptButtonTapped()
    func model(for indexPath: IndexPath) -> PartCellModel
}

final class PartPayPresenter: PartPayPresenting {
    private var partPayService: PartPayService
    private let router: PartPayRouter
    private let timeManager: OptimizationCheсkerManager
    private let analytics: AnalyticsService
    private var checkTapped: Bool = false

    weak var view: (IPartPayVC & ContentVC)?
    
    private var payParts: [PartCellModel]
    
    var partsCount: Int {
        payParts.count
    }

    init(_ router: PartPayRouter,
         partPayService: PartPayService,
         timeManager: OptimizationCheсkerManager,
         analytics: AnalyticsService,
         selectedCard: @escaping (PaymentToolInfo) -> Void) {
        self.partPayService = partPayService
        self.router = router
        self.analytics = analytics
        self.timeManager = timeManager
        self.timeManager.startTraking()
        let model1 = PartCellModel(title: "Оплатите сейчас",
                                   cost: 2000.price(),
                                   isSelected: true,
                                   hideLine: false)
        let model2 = PartCellModel(title: "Оплатите завтра",
                                   cost: 2000.price(),
                                   isSelected: false,
                                   hideLine: false)
        let model3 = PartCellModel(title: "Оплатите завтра",
                                   cost: 2000.price(),
                                   isSelected: false,
                                   hideLine: false)
        let model4 = PartCellModel(title: "Оплатите завтра",
                                   cost: 2000.price(),
                                   isSelected: false,
                                   hideLine: true)
        payParts = [model1, model2, model3, model4]
    }
    
    func viewDidLoad() {
        timeManager.endTraking(CardsVC.self.description()) {
            analytics.sendEvent(.CardsViewAppeared, with: [$0])
        }
        view?.setFinalCost(1600000.price())
        checkTapped = partPayService.bnplplanSelected
        view?.setButtonEnabled(value: checkTapped)
    }

    func checkTapped(_ value: Bool) {
        view?.setButtonEnabled(value: value)
    }
    
    func agreementViewTapped() {
        router.presentWebView(with: "https://www.google.com/webhp?hl=en&sa=X&ved=0ahUKEwin0I3W3cX-AhWDqIsKHVurAGIQPAgJ")
    }
    
    func acceptButtonTapped() {
        partPayService.bnplplanSelected = checkTapped
    }
    
    func model(for indexPath: IndexPath) -> PartCellModel {
        // DEBUG
        return payParts[indexPath.row]
    }
}
