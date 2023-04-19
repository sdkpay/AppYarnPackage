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

final class CardInfoView: UICollectionViewCell {
    private var needArrow = false
    static var reuseID: String { "CardInfoView" }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = 8.0
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
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
                needArrow: Bool) {
        titleLabel.text = title
        subtitleLabel.text = cardInfo
        self.needArrow = needArrow
        cardIconView.downloadImage(from: cardIconURL)
    }
    
    private func setupUI() {
        cardIconView
            .add(toSuperview: contentView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .centerInSuperview(.y)
            .size(.init(width: .cardWidth, height: .cardWidth))

        cardInfoStack
            .add(toSuperview: contentView)
            .touchEdge(.left, toEdge: .right, ofView: cardIconView, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .centerInSuperview(.y)
        
        if needArrow {
            arrowView
                .add(toSuperview: contentView)
                .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
                .centerInSuperview(.y)
                .size(.init(width: .arrowWidth, height: .arrowWidth))
        }
    }
}
