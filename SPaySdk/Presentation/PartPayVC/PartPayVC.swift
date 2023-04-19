//
//  PartPayVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

private extension CGFloat {
    static let topMargin = 24.0
    static let bottomMargin = 44.0
    static let buttonsMargin = 10.0
    static let rowHeight = 50.0
}

protocol IPartPayVC {
    func setFinalCost(_ value: String)
}

final class PartPayVC: ContentVC, IPartPayVC {
    private lazy var titleLabel: UILabel = {
       let view = UILabel()
        view.font = .header
        view.textColor = .textPrimory
        view.text = .PayPart.title
        return view
    }()
    
    private lazy var subTitleLabel: UILabel = {
       let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        view.text = .PayPart.subtitle
        return view
    }()
    
    private lazy var acceptButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(String(stringLiteral: .PayPart.accept), for: .normal)
        view.addAction { [weak self] in
            self?.agreementView.shake()
        }
        return view
    }()
    
    private lazy var cancelButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .info)
        view.setTitle(String(stringLiteral: .PayPart.cancel), for: .normal)
        return view
    }()
    
    private lazy var agreementView: CheckView = {
        let view = CheckView()
        let text = NSAttributedString(text: .PayPart.acceptDoc,
                                      dedicatedPart: .PayPart.acceptDocColor,
                                      attrebutes: [.foregroundColor: UIColor.main])
        view.config(with: text, checkTapped: {}, textTapped: {})
        return view
    }()
    
    private lazy var finalLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi1
        view.textColor = .textPrimory
        view.text = .PayPart.final
        return view
    }()
    
    private lazy var finalCostLabel: UILabel = {
       let view = UILabel()
        view.font = .bodi1
        view.textColor = .textPrimory
        return view
    }()
    
    private lazy var finalStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.addArrangedSubview(finalLabel)
        view.addArrangedSubview(finalCostLabel)
        return view
    }()
    
    private lazy var partsTableView: ContentTableView = {
        let view = ContentTableView()
        view.register(PartCell.self, forCellReuseIdentifier: PartCell.reuseId)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = false
        view.rowHeight = .rowHeight
        view.dataSource = self
        return view
    }()
    
    private lazy var backgroundTableView: UIView = {
        let view = UIView()
        view.setupForBase()
        return view
    }()
    
    private let presenter: PartPayPresenter
        
    init(_ presenter: PartPayPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBarIsHidden = true
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
    
    func setFinalCost(_ value: String) {
        finalCostLabel.text = value
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(backgroundTableView)
        backgroundTableView.addSubview(partsTableView)
        backgroundTableView.addSubview(finalStack)
        view.addSubview(cancelButton)
        view.addSubview(acceptButton)
        view.addSubview(agreementView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: .topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin)
        ])
        
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin)
        ])
        
        backgroundTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundTableView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor),
            backgroundTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            backgroundTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin)
        ])
        
        partsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            partsTableView.topAnchor.constraint(equalTo: backgroundTableView.topAnchor, constant: .margin),
            partsTableView.leadingAnchor.constraint(equalTo: backgroundTableView.leadingAnchor, constant: .margin),
            partsTableView.trailingAnchor.constraint(equalTo: backgroundTableView.trailingAnchor, constant: -.margin)
        ])
        
        finalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            finalStack.topAnchor.constraint(equalTo: partsTableView.bottomAnchor),
            finalStack.leadingAnchor.constraint(equalTo: backgroundTableView.leadingAnchor, constant: .margin),
            finalStack.trailingAnchor.constraint(equalTo: backgroundTableView.trailingAnchor, constant: -.margin),
            finalStack.heightAnchor.constraint(equalToConstant: .rowHeight),
            finalStack.bottomAnchor.constraint(equalTo: backgroundTableView.bottomAnchor, constant: -.margin)
        ])
        
        agreementView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            agreementView.topAnchor.constraint(equalTo: backgroundTableView.bottomAnchor, constant: .bottomMargin),
            agreementView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            agreementView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            agreementView.bottomAnchor.constraint(equalTo: acceptButton.topAnchor, constant: -.bottomMargin)
        ])
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -.bottomMargin),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            cancelButton.heightAnchor.constraint(equalToConstant: .defaultButtonHeight)
        ])
        
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            acceptButton.heightAnchor.constraint(equalToConstant: .defaultButtonHeight),
            acceptButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            acceptButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -.buttonsMargin)
        ])
    }
}

extension PartPayVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.partsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PartCell.reuseId) as? PartCell
        else { return UITableViewCell() }
        cell.selectionStyle = .none
        let model = presenter.model(for: indexPath)
        cell.config(with: model)
        return cell
    }
}
