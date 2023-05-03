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
    func acceptButtonTapped()
    func backButtonTapped()
    func model(for indexPath: IndexPath) -> PartCellModel
}

final class PartPayPresenter: PartPayPresenting {
    private var partPayService: PartPayService
    private let router: PartPayRouter
    private let timeManager: OptimizationCheсkerManager
    private let analytics: AnalyticsService
    private var partPaySelected: Action
    private var checkTapped = false

    weak var view: (IPartPayVC & ContentVC)?
    
    var partsCount: Int {
        partPayService.bnplplan?.graphBnpl?.payments.count ?? 0
    }

    init(_ router: PartPayRouter,
         partPayService: PartPayService,
         timeManager: OptimizationCheсkerManager,
         analytics: AnalyticsService,
         partPaySelected: @escaping Action) {
        self.partPayService = partPayService
        self.router = router
        self.analytics = analytics
        self.timeManager = timeManager
        self.partPaySelected = partPaySelected
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        timeManager.endTraking(CardsVC.self.description()) {
            analytics.sendEvent(.CardsViewAppeared, with: [$0])
        }
        configViews()
        configCheckView()
    }
    
    private func configViews() {
        if let plan = partPayService.bnplplan?.graphBnpl {
            view?.setFinalCost(plan.finalCost.price(CurrencyCode(rawValue: 643) ?? .RUB))
        }
        checkTapped = partPayService.bnplplanSelected
        view?.setButtonEnabled(value: checkTapped)
        view?.setSubtitle(partPayService.bnplplan?.graphBnpl?.header ?? "")
    }

    private func configCheckView() {
        let text = NSAttributedString(markedText: partPayService.bnplplan?.offerText ?? "",
                                      attrebutes: [.foregroundColor: UIColor.main])
        view?.configCheckView(text: text,
                              checkTapped: { [weak self] value in
            self?.checkTapped(value)
        },
                              textTapped: { [weak self] in
            self?.agreementViewTapped()
        })
    }

    private func checkTapped(_ value: Bool) {
        view?.setButtonEnabled(value: value)
    }
    
    private func agreementViewTapped() {
        router.presentWebView(with: partPayService.bnplplan?.offerUrl ?? "",
                              title: .PayPart.agreement )
    }
    
    func acceptButtonTapped() {
        partPayService.bnplplanSelected = true
        partPaySelected()
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    func backButtonTapped() {
        partPayService.bnplplanSelected = false
        partPaySelected()
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    func model(for indexPath: IndexPath) -> PartCellModel {
        guard let parts = partPayService.bnplplan?.graphBnpl?.payments else {
            return PartCellModel(title: "", cost: "", isSelected: true, hideLine: true)
        }
        let part = parts[indexPath.row]
        return PartCellModel(title: part.date,
                             cost: part.amount.price(CurrencyCode(rawValue: 643) ?? .RUB),
                             isSelected: indexPath.row == 0,
                             hideLine: indexPath.row == parts.count - 1)
    }
}
