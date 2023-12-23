//
//  SquarePaymentFeatureCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 13.11.2023.
//

import UIKit

private extension CGFloat {
    static let cardWidth = 36.0
    static let sideMargin = 20.0
    static let letterSpacing = -0.4
}

final class SquarePaymentFeatureCell: UICollectionViewCell, SelfReusable, SelfConfigCell {
    
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
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.letterSpacing(.letterSpacing)
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium2
        view.numberOfLines = 0
        view.textColor = .textSecondary
        view.letterSpacing(.letterSpacing)
        return view
    }()
    
    private lazy var cardIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var infoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(subtitleLabel)
        return view
    }()
    
    private lazy var switchControl: DefaultSwitch = {
        let view = DefaultSwitch(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    func config<U>(with model: U) where U: AbstractCellModel {
        guard let model = model.map(type: PaymentFeatureModel.self) else { return }
        titleLabel.text = model.title
        subtitleLabel.text = model.subTitle
        switchControl.isOn = model.switchOn 
        cardIconView.downloadImage(from: model.iconViewURL)
        
        if model.switchNeed {
            infoStack.addArrangedSubview(switchControl)
        }
        
        setupUI()
    }

    private func setupUI() {
        
        cardIconView
            .add(toSuperview: contentView)
            .touchEdge(.top, toEdge: .top, ofView: contentView, withInset: .sideMargin)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .size(.init(width: .cardWidth, height: .cardWidth))
    
        infoStack
            .add(toSuperview: contentView)
            .touchEdge(.top, toEdge: .bottom, ofView: cardIconView, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
    }
}
