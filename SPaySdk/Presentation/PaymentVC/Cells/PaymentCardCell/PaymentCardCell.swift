//
//  PaymentCardCell.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

private extension CGFloat {
    static let arrowWidth = 24.0
    static let cardWidth = 36.0
    static let letterSpacing = -0.4
}

final class PaymentCardCell: UICollectionViewCell, SelfReusable, SelfConfigCell {
    
    private var needArrow = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundPrimary
        layer.cornerRadius = 20.0
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium5
        view.textColor = .textPrimory
        view.letterSpacing(.letterSpacing)
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium2
        view.textColor = .textSecondary
        view.letterSpacing(.letterSpacing)
        return view
    }()
    
    private lazy var cardIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
    
    func config<U>(with model: U) where U: AbstractCellModel {
        guard let model = model.map(type: CardModel.self) else { return }
        titleLabel.text = model.title
        subtitleLabel.text = model.subTitle
        self.needArrow = model.needArrow
        cardIconView.downloadImage(from: model.iconViewURL)
        setupUI()
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
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .margin)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .margin)
        
        if needArrow {
            arrowView
                .add(toSuperview: contentView)
                .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
                .centerInSuperview(.y)
                .size(.init(width: .arrowWidth, height: .arrowWidth))
        }
    }
}
