//
//  CardCell.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

struct CardCellModel {
    let title: String
    let number: String
    let selected: Bool
}

private extension CGFloat {
    static let topMargin = 12.0
    static let corner = 8.0
    static let checkWidth = 20.0
}

final class CardCell: UITableViewCell {
    static var reuseId: String { "CardCell" }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .corner
        return view
    }()

    private lazy var titleLabel: UILabel = {
       let view = UILabel()
        view.font = .bodi1
        view.textColor = .textPrimory
        return view
    }()
    
    private lazy var cardLabel: UILabel = {
       let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        return view
    }()
    
    private lazy var checkImageView = UIImageView()
    
    private lazy var cardInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
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
        containerView.backgroundColor = model.selected ? .mainSecondary : .backgroundSecondary
        checkImageView.image = model.selected ? .Common.checkSelected : .Common.checkDeselected
        titleLabel.text = model.title
        cardLabel.text = model.number
    }
    
    private func setupUI() {
        backgroundColor = .backgroundPrimary
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
        
        containerView.addSubview(cardInfoStack)
        cardInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardInfoStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
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
