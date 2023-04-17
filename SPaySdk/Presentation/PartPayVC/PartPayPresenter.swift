//
//  PartPayPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

protocol PartPayPresenting {
    func viewDidLoad()
}

final class PartPayPresenter: PartPayPresenting {
    private let timeManager: OptimizationCheсkerManager
    private let analytics: AnalyticsService

    weak var view: (IPartPayVC & ContentVC)?

    init(timeManager: OptimizationCheсkerManager,
         analytics: AnalyticsService,
         selectedCard: @escaping (PaymentToolInfo) -> Void) {
        self.analytics = analytics
        self.timeManager = timeManager
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        timeManager.endTraking(CardsVC.self.description()) {
            analytics.sendEvent(.CardsViewAppeared, with: [$0])
        }
    }
}
