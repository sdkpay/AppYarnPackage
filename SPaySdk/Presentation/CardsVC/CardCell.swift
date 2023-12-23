//
//  CardCell.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

struct CardCellModel {
    let title: String
    let subtitle: String
    let selected: Bool
    let cardURL: String?
}

private extension CGFloat {
    static let topMargin = 8.0
    static let corner = 20.0
    static let checkWidth = 20.0
    static let cardWidth = 36.0
    static let letterSpacing = -0.3
}

final class CardCell: UITableViewCell {    
    
    private lazy var containerView: UIView = {
        let view = UIView()
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified, .light:
            view.backgroundColor = .backgroundPrimary
        case .dark:
            view.applyBlurEffect(style: .systemUltraThinMaterial)
        @unknown default:
            view.backgroundColor = .backgroundPrimary
        }
        
        view.clipsToBounds = true
        view.layer.cornerRadius = .corner
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium7
        view.textColor = .textPrimory
        view.letterSpacing(.letterSpacing)
        return view
    }()
    
    private lazy var cardLabel: UILabel = {
        let view = UILabel()
        view.font = .medium2
        view.textColor = .textSecondary
        return view
    }()
    
    private var cardIconView = UIImageView()
    private lazy var checkImageView = UIImageView()
    
    private lazy var cardInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(cardLabel)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with model: CardCellModel) {
        titleLabel.text = model.title
        cardLabel.text = model.subtitle
        cardIconView.downloadImage(from: model.cardURL, placeholder: .Cards.stockCard)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(cardLabel)
        containerView.addSubview(checkImageView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.topMargin)
        ])
        
        containerView.addSubview(cardIconView)
        cardIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            cardIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            cardIconView.widthAnchor.constraint(equalToConstant: .cardWidth),
            cardIconView.heightAnchor.constraint(equalToConstant: .cardWidth)
        ])
        
        containerView.addSubview(cardInfoStack)
        cardInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardInfoStack.leadingAnchor.constraint(equalTo: cardIconView.trailingAnchor, constant: .margin),
            cardInfoStack.trailingAnchor.constraint(equalTo: checkImageView.leadingAnchor, constant: -.margin),
            cardInfoStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkImageView.widthAnchor.constraint(equalToConstant: .checkWidth),
            checkImageView.heightAnchor.constraint(equalToConstant: .checkWidth),
            checkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
            checkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}
