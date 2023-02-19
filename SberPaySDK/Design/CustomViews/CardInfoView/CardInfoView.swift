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
    static let noCardHeight = 36.0
}

final class CardInfoView: ContentView {
    private var needArrow = false

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi1
        view.textColor = .textPrimory
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        return view
    }()
    
    private var cardIconView: UIImageView = {
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
        view.addArrangedSubview(subtitleLabel)
        return view
    }()

    func config(with title: String,
                cardInfo: String,
                cardIconURL: String?,
                needArrow: Bool,
                action: @escaping Action) {
        titleLabel.text = title
        subtitleLabel.text = cardInfo
        self.needArrow = needArrow
        self.action = action

        ImageDownloadService.shared.downloadImage(with: cardIconURL,
                                                  completionHandler: { [weak self] icon, _ in
            self?.cardIconView.image = icon
        }, placeholderImage: .Cards.stockCard)

        setupUI()
    }

    private func setupUI() {
        addSubview(cardIconView)
        cardIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .leadingMargin),
            cardIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardIconView.widthAnchor.constraint(equalToConstant: .cardWidth),
            cardIconView.heightAnchor.constraint(equalToConstant: .cardHeight)
        ])

        addSubview(cardInfoStack)
        cardInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardInfoStack.leadingAnchor.constraint(equalTo: cardIconView.trailingAnchor, constant: .margin),
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
