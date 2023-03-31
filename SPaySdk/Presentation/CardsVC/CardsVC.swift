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
    private var timeManager = OptimizationCheсkerManager()
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        view.text = String(stringLiteral: .Cards.cardsTitle)
        return view
    }()
    
    private lazy var tableView: ContentTableView = {
        let view = ContentTableView()
        view.register(CardCell.self, forCellReuseIdentifier: CardCell.reuseId)
        view.separatorStyle = .none
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
        timeManager.startTraking()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeManager.endTraking(String(describing: self))
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
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: .topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .tableMargin),
            tableView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.bottomMargin)
        ])
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
