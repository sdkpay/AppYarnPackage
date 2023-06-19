//
//  CardsVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

private extension CGFloat {
    static let topMargin = 20.0
    static let tableMargin = 12.0
    static let bottomMargin = 58.0
    static let rowHeight = 84.0
}

protocol ICardsVC { }

final class CardsVC: ContentVC, ICardsVC {
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        view.text = String(stringLiteral: Strings.Cards.title)
        return view
    }()
    
    private lazy var tableView: ContentTableView = {
        let view = ContentTableView()
        view.register(CardCell.self, forCellReuseIdentifier: CardCell.reuseId)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.backgroundView?.backgroundColor = .backgroundPrimary
        view.showsVerticalScrollIndicator = false
        view.rowHeight = .rowHeight
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private let presenter: CardsPresenting
    
    init(_ presenter: CardsPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
    }
    
    private func setupUI() {
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImage, withInset: .topMargin)
            .touchEdge(.left, toEdge: .left, ofView: logoImage)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)

        tableView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: .tableMargin)
            .touchEdge(.left, toEdge: .left, ofView: titleLabel)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .bottomMargin)
    }
}

extension CardsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.cardsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardCell.reuseId) as? CardCell
        else { return UITableViewCell() }
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
