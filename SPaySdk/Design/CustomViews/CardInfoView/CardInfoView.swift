//
//  CardInfoView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

private extension CGFloat {
    static let arrowWidth = 24.0
    static let cardWidth = 36.0
}

final class CardInfoView: ContentView, SBShimmeringView {
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
    
    private lazy var cardIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
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
        setupUI()
        cardIconView.downloadImage(from: cardIconURL)
    }
    
    private func setupUI() {
        addSubview(cardIconView)
        cardIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            cardIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardIconView.widthAnchor.constraint(equalToConstant: .cardWidth),
            cardIconView.heightAnchor.constraint(equalToConstant: .cardWidth)
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
