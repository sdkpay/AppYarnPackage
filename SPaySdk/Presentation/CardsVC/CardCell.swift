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
    let bonuses: String?
    let cardURL: String?
    let isEnoughtMoney: Bool
}

private extension CGFloat {
    static let topMargin = 8.0
    static let corner = 20.0
    static let checkWidth = 20.0
    static let cardWidth = 36.0
    static let letterSpacing = -0.3
    static let bonusesStackInset = 16.0
    static let bonusesLabelHeight = 17.0
    static let horizontalInset = 16.0
}

final class CardCell: UITableViewCell, Shakable {
    
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
    
    private lazy var bonusesLabel: LinkLabel = {
        let view = LinkLabel()
        view.font = .medium2
        view.numberOfLines = 0
        view.textColor = .white
        return view
    }()
    
    private lazy var bonusesImageView = UIImageView(image: Asset.Image.sbsp.image.withRenderingMode(.alwaysTemplate))
    
    private lazy var bonusesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.isHidden = true
        stackView.addArrangedSubview(bonusesLabel)
        stackView.addArrangedSubview(bonusesImageView)
        stackView.alignment = .center
        return stackView
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
        if let bonuses = model.bonuses,
           model.isEnoughtMoney {
            bonusesStackView.isHidden = false
            bonusesLabel.text = "+\(bonuses)"
            let bonusesColor = model.selected ? Asset.Palette.greenPrimary.color : Asset.Palette.grayPrimary.color
            bonusesLabel.textColor = bonusesColor
            bonusesImageView.tintColor = bonusesColor
        } else {
            bonusesStackView.isHidden = true
        }
        if !model.isEnoughtMoney {
            titleLabel.textColor = .textSecondary
            cardLabel.textColor = .textSecondary
        }
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 8, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 8, y: self.center.y))

        self.layer.add(animation, forKey: "position")
        UINotificationFeedbackGenerator().notificationOccurred(.error)
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
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .horizontalInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.horizontalInset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.topMargin)
        ])
        
        containerView.addSubview(cardIconView)
        cardIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: .margin),
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
        
        bonusesStackView
            .add(toSuperview: containerView)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .bonusesStackInset)
            .centerInSuperview(.y)
        
        bonusesLabel
            .height(.equal, to: .bonusesLabelHeight)
    }
}
