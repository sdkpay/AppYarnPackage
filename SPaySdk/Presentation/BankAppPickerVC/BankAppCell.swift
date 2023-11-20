//
//  BankAppCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.10.2023.
//

import UIKit

struct BankAppCellModel {
    let title: String
    let iconURL: String?
    let link: String
    
    var deprecated = false
    var tapped = false
    
    init(with bankApp: BankApp) {
        title = bankApp.name
        link = bankApp.authLink
        iconURL = bankApp.iconURL
    }
}

private extension CGFloat {
    static let topMargin = 12.0
    static let corner = 20.0
    static let checkWidth = 20.0
    static let cardWidth = 36.0
    static let letterSpacing = -0.3
}

final class BankAppCell: UITableViewCell {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .corner
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium1
        view.textColor = .backgroundPrimary
        view.letterSpacing(.letterSpacing)
        return view
    }()
    
    private lazy var sutitleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium3
        view.textColor = .textSecondary
        return view
    }()
    
    private var bankIconView = UIImageView()
    
    private lazy var cardInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(sutitleLabel)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with model: BankAppCellModel) {
        titleLabel.text = model.title
        sutitleLabel.text = model.deprecated.description
        
        switch model.deprecated {
        case true:
            sutitleLabel.text = Strings.BankAppPicker.deprecated
            sutitleLabel.textColor = .notification
        case false:
            sutitleLabel.text = nil
        }
        
        bankIconView.downloadImage(from: model.iconURL, placeholder: .Cards.stockCard)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(sutitleLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.topMargin)
        ])
        
        containerView.addSubview(bankIconView)
        bankIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bankIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            bankIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bankIconView.widthAnchor.constraint(equalToConstant: .cardWidth),
            bankIconView.heightAnchor.constraint(equalToConstant: .cardWidth)
        ])
        
        containerView.addSubview(cardInfoStack)
        cardInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardInfoStack.leadingAnchor.constraint(equalTo: bankIconView.trailingAnchor, constant: .margin),
            cardInfoStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -.margin),
            cardInfoStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}
