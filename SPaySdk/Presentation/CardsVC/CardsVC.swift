//
//  CardsVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

extension CGFloat {
    static let headerHeight = 54.0
}

protocol ICardsVC {
    func reloadTableView()
    func setCostUI(_ cost: Int)
}

final class CardsVC: ContentVC, ICardsVC {
    
    private let presenter: CardsPresenting
    private let analytics: AnalyticsManager
    private let viewBuilder = CardsViewBuilder()
    
    init(_ presenter: CardsPresenting,
         analytics: AnalyticsManager) {
        self.presenter = presenter
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
        analyticsName = .ListCardView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        viewBuilder.setupUI(view: view)
        viewBuilder.tableView.delegate = self
        viewBuilder.tableView.dataSource = self
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
        analytics.sendAppeared(view: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
        analytics.sendDisappeared(view: self)
    }
    
    func reloadTableView() {
        UIView.transition(with: viewBuilder.tableView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.viewBuilder.tableView.reloadData() },
                          completion: nil)
    }
    
    func setCostUI(_ cost: Int) {
        viewBuilder.costLabel.text = cost.price()
    }
}

extension CardsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return presenter.enougthCardsCount
        } else {
            return presenter.notEnougthCardsCount
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.sectionsCount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? .headerHeight : .zero
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 1 ? NotEnoughtHeaderView() : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CardCell = tableView.dequeueResuableCell(forIndexPath: indexPath)
        cell.selectionStyle = .none
        let model = presenter.model(for: indexPath)
        cell.config(with: model)
        return cell
    }
}

extension CardsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            presenter.didSelectRow(at: indexPath)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as? CardCell
            cell?.shake()
        }
    }
}
