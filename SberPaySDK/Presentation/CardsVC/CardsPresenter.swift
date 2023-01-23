//
//  CardsPresenter.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

protocol CardsPresenting {
    func viewDidLoad()
    func didSelectRow(at indexPath: IndexPath)
}

final class CardsPresenter: CardsPresenting {
    private let manager: SDKManager
    private let analytics: AnalyticsService

    weak var view: (ICardsVC & ContentVC)?

    init(manager: SDKManager,
         analytics: AnalyticsService) {
        self.manager = manager
        self.analytics = analytics
    }
    
    func viewDidLoad() {
        configViews()
        analytics.sendEvent(.CardsViewAppeared)
    }
    
    private func configViews() {
        view?.configProfileView(with: "Маргарита Т.", gender: .female)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        // DEBUG
        view?.contentNavigationController?.popViewController(animated: true)
    }
}
