//
//  CardInfoView.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

private extension CGFloat {
    static let arrowWidth = 24.0
    static let leadingMargin = 20.0
    static let cardWidth = 28.0
    static let cardHeight = 20.0
}

final class CardInfoView: ContentView {
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
    
    private var cardIcon: UIImageView = {
        let view = UIImageView()
        view.image = .Cards.stockCard
        return view
    }()
    
    private lazy var arrowView: UIImageView = {
       let view = UIImageView()
        view.image = .Payment.arrow
        return view
    }()
    
    private lazy var cardInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(cardLabel)
        return view
    }()
    
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var needArrow = false
    
    func config(with title: String,
                cardInfo: String,
                needArrow: Bool,
                action: @escaping Action) {
        titleLabel.text = title
        cardLabel.text = cardInfo
        self.needArrow = needArrow
        self.action = action
        setupUI()
    }
    
    private func setupUI() {
        addSubview(cardIcon)
        cardIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .leadingMargin),
            cardIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardIcon.widthAnchor.constraint(equalToConstant: .cardWidth),
            cardIcon.heightAnchor.constraint(equalToConstant: .cardHeight)
        ])

        addSubview(cardInfoStack)
        cardInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardInfoStack.leadingAnchor.constraint(equalTo: cardIcon.trailingAnchor, constant: .margin),
            cardInfoStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
            cardInfoStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        if needArrow {
            addSubview(arrowView)
            arrowView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
                arrowView.centerYAnchor.constraint(equalTo: centerYAnchor),
                arrowView.widthAnchor.constraint(equalToConstant: .arrowWidth),
                arrowView.heightAnchor.constraint(equalToConstant: .arrowWidth)
            ])
        }
    }
}
