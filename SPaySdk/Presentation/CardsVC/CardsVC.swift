//
//  CardsVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

protocol ICardsVC { }

final class CardsVC: ContentVC, ICardsVC {
    
    private let presenter: CardsPresenting
    private let analytics: AnalyticsManager
    private let viewBuilder = CardsViewBuilder()
    
    init(_ presenter: CardsPresenting,
         analytics: AnalyticsManager,
         cost: String) {
        self.presenter = presenter
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
        analyticsName = .ListCardView
        viewBuilder.costLabel.text = cost
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
}

extension CardsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.cardsCount
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
        presenter.didSelectRow(at: indexPath)
    }
}
