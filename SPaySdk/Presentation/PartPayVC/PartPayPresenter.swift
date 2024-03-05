//
//  PartPayPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

protocol PartPayPresenting {
    func viewDidLoad()
    var partsCount: Int { get }
    func acceptButtonTapped()
    func backButtonTapped()
    func model(for indexPath: IndexPath) -> PartCellModel
}

final class PartPayPresenter: PartPayPresenting {
    
    weak var view: (IPartPayVC & ContentVC)?
    
    var partsCount: Int {
        partPayService.bnplplan?.graphBnpl?.parts.count ?? 0
    }

    private var partPayService: PartPayService
    private let router: PartPayRouter
    private let timeManager: OptimizationCheсkerManager
    private let analytics: AnalyticsService
    private var partPaySelected: Action
    private var isSelected = true
    private var screenEvents = [AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]

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
        configViews()
        configCheckView()
    }
    
    func acceptButtonTapped() {
        analytics.sendEvent(.TouchConfirmedByUser,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        partPayService.bnplplanSelected = true
        partPaySelected()
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: true)
        }
    }
    
    func backButtonTapped() {
        analytics.sendEvent(.TouchDeclinedByUser,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        partPayService.bnplplanSelected = false
        partPaySelected()
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: true)
        }
    }
    
    func model(for indexPath: IndexPath) -> PartCellModel {
        
        guard let parts = partPayService.bnplplan?.graphBnpl?.parts,
              let text = partPayService.bnplplan?.graphBnpl?.text else {
            return PartCellModel(title: "", cost: "", isSelected: true, hideLine: true)
        }
        let part = parts[indexPath.row]
        return PartCellModel(title: indexPath.row == 0 ? text : part.date,
                             cost: part.amount.price(part.currencyCode),
                             isSelected: indexPath.row == 0,
                             hideLine: indexPath.row == parts.count - 1)
    }
    
    private func configViews() {
        if let plan = partPayService.bnplplan?.graphBnpl {
            view?.setFinalCost(plan.finalCost.price(plan.currencyCode))
        }
        view?.setTitle(partPayService.bnplplan?.graphBnpl?.header ?? "")
    }

    private func configCheckView() {
        view?.configCheckView(text: partPayService.bnplplan?.offerText ?? "",
                              checkSelected: isSelected,
                              checkTapped: { [weak self] value in
            self?.checkTapped(value)
        },
                              textTapped: { [weak self] link in
            DispatchQueue.main.async {
                self?.agreementTextTapped(link: link.link)
            }
        })
    }

    private func checkTapped(_ value: Bool) {
        analytics.sendEvent(.TouchApproveBNPL,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        view?.setButtonEnabled(value: value)
    }
    
    @MainActor
    private func agreementTextTapped(link: String) {
        analytics.sendEvent(.TouchAgreementView,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        router.presentWebView(with: link)
    }
}
