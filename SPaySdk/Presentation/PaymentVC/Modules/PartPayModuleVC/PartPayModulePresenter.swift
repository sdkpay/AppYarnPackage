//
//  PartPayModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 03.03.2024.
//

import UIKit

struct PartCellModel {
    let title: String
    let cost: String
    let isSelected: Bool
    let hideLine: Bool
}

protocol PartPayModulePresenting {
    func viewDidLoad()
    var partsCount: Int { get }
    func model(for indexPath: IndexPath) -> PartCellModel
    var needCommission: Bool { get }
    
    var view: (IPartPayModuleVC & ModuleVC)? { get set }
}

final class PartPayModulePresenter: NSObject, PartPayModulePresenting {
    
    var partsCount: Int {
        partPayService.bnplplan?.graphBnpl?.parts.count ?? 0
    }
    
    var needCommission: Bool {
        partPayService.bnplplan?.graphBnpl?.commission != nil
    }
    
    weak var view: (IPartPayModuleVC & ModuleVC)?
    private let router: PartPayModuleRouting
    private var userService: UserService
    private let analytics: AnalyticsService
    private var partPayService: PartPayService
    
    init(_ router: PartPayModuleRouting,
         partPayService: PartPayService,
         analytics: AnalyticsService,
         userService: UserService) {
        self.router = router
        self.partPayService = partPayService
        self.userService = userService
        self.analytics = analytics
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
    }
    
    private func configViews() {
        if let plan = partPayService.bnplplan?.graphBnpl {
            view?.setFinalCost(plan.finalCost.price(plan.currencyCode))
        }
        view?.setTitle(partPayService.bnplplan?.graphBnpl?.header ?? "")
        configCheckView()
        
        if let commissionCount = partPayService.bnplplan?.graphBnpl?.commission {
            view?.setCommissionCount(commissionCount)
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
    
    private func configCheckView() {
        view?.configCheckView(text: partPayService.bnplplan?.offerText ?? "",
                              checkSelected: partPayService.bnplCheckAccepted,
                              checkTapped: { [weak self] value in
            self?.analytics.sendEvent(.TouchApproveBNPL,
                                      with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
            self?.partPayService.bnplCheckAccepted = value
        },
                              textTapped: { [weak self] link in
            DispatchQueue.main.async {
                self?.agreementTextTapped(link: link.link)
            }
        })
    }
    
    @MainActor
    private func agreementTextTapped(link: String) {
        analytics.sendEvent(.TouchAgreementView,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        router.presentWebView(with: link)
    }
}
