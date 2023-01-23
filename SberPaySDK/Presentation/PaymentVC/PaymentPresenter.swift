//
//  PaymentPresenter.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import Foundation

protocol PaymentPresenting {
    func viewDidLoad()
    func payButtonTapped()
    func cancelTapped()
}

final class PaymentPresenter: PaymentPresenting {
    private let manager: SDKManager
    private let analytics: AnalyticsService

    weak var view: (IPaymentVC & ContentVC)?
    
    init(_ manager: SDKManager, analytics: AnalyticsService) {
        self.manager = manager
        self.analytics = analytics
    }
    
    func viewDidLoad() {
        configViews()
        analytics.sendEvent(.PayViewAppeared)
    }
    
    func payButtonTapped() {
        // DEBUG
        analytics.sendEvent(.PayConfirmedByUser)
        view?.showAlert(with: .failure())
    }
    
    func cancelTapped() {
        view?.dismiss(animated: true)
    }
    
    private func configViews() {
        // DEBUG
        guard let cost = manager.request?.amount,
              let name = manager.request?.clientName
        else { return }
        view?.configShopInfo(with: name, cost: cost.price)
        // DEBUG
        view?.configCardView(with: "СберКарта", cardInfo: "*** 5585") { [weak self] in
            self?.openCardsVC()
        }
        // DEBUG
        view?.configProfileView(with: "Маргарита Т.", gender: .female)
    }
    
    private func openCardsVC() {
        let vc = CardsAssembly().createModule(manager: manager, analytics: analytics)
        view?.contentNavigationController?.pushViewController(vc, animated: true)
    }
}
