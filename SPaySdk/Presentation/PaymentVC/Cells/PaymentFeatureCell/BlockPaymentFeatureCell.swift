//
//  BlockPaymentFeatureCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 13.11.2023.
//

import UIKit

private extension CGFloat {
    static let cellMargin = 16.0
    static let cardWidth = 36.0
    static let letterSpacing = -0.4
}

final class BlockPaymentFeatureCell: UICollectionViewCell, SelfReusable, SelfConfigCell {
    
    private var switchOn = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundPrimary
        layer.cornerRadius = 20.0
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
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var switchControl: UISwitch = {
        let view = UISwitch(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var infoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(subtitleLabel)
        return view
    }()
    
    func config<U>(with model: U) where U: AbstractCellModel {
        guard let model = model.map(type: PaymentFeatureModel.self) else { return }
        titleLabel.text = model.title
        subtitleLabel.text = model.subTitle
        self.switchControl.isOn = model.switchOn
        iconView.downloadImage(from: model.iconViewURL)
        
        setupUI(needSwitch: model.switchNeed)
    }

    private func setupUI(needSwitch: Bool) {
        iconView
            .add(toSuperview: contentView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .centerInSuperview(.y)
            .size(.init(width: .cardWidth, height: .cardWidth))

        infoStack
            .add(toSuperview: contentView)
            .touchEdge(.left, toEdge: .right, ofView: iconView, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .cellMargin)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .cellMargin, priority: .defaultHigh)
        
        if needSwitch {
            switchControl
                .add(toSuperview: contentView)
                .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
                .centerInSuperview(.y)
        }
    }
}
