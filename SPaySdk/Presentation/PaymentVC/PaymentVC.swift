//
//  PaymentVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

private extension CGFloat {
    static let bottomMargin = 44.0
    static let topMargin = 22.0
    static let buttonsMargin = 10.0
    static let purchaseMargin = 2.0
    static let cartWidth = 56.0
    static let inset = 16.0
    static let spacing = 16.0
    static let itemHeight = 72.0
}

enum PaymentCellType {
    case cards
    case parts
}

struct PaymentModel {
    var cardName: String
    var cardInfo: String
    var cardIconURL: String?
    var needArrow: Bool
    var type: PaymentCellType
}

protocol IPaymentVC {
    func configShopInfo(with shop: String, cost: String, iconURL: String?)
    func configCardView(with cardName: String,
                        cardInfo: String,
                        cardIconURL: String?,
                        needArrow: Bool,
                        action: @escaping Action)
}

final class PaymentVC: ContentVC, IPaymentVC {
    private var models: [PaymentModel] = []
    private var cardsDidTap: Action?
    
    private lazy var payButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(String(stringLiteral: .Common.payTitle), for: .normal)
        view.addAction { [weak self] in
            self?.presenter.payButtonTapped()
        }
        return view
    }()
    
    private lazy var cancelButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
        view.setTitle(String(stringLiteral: .Common.cancelTitle), for: .normal)
        view.addAction { [weak self] in
            self?.presenter.cancelTapped()
        }
        return view
    }()
    
    private lazy var shopLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        return view
    }()
    
    private lazy var costLabel: UILabel = {
        let view = UILabel()
        view.font = .header
        view.textColor = .textPrimory
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var purchaseInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(shopLabel)
        view.addArrangedSubview(costLabel)
        return view
    }()
    
    private lazy var collectionView: CompactCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(
            width: UIScreen.main.bounds.width - (.inset * 2),
            height: .itemHeight
        )
        layout.minimumLineSpacing = .spacing
        let collectionView = CompactCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CardInfoView.self, forCellWithReuseIdentifier: CardInfoView.reuseID)
        return collectionView
    }()
    
    private var presenter: PaymentPresenting
    
    init(_ presenter: PaymentPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
    }
    
    func configShopInfo(with shop: String, cost: String, iconURL: String?) {
        shopLabel.text = shop
        costLabel.text = cost
        logoImageView.downloadImage(from: iconURL, placeholder: .Payment.cart)
    }
    
    func configCardView(with cardName: String,
                        cardInfo: String,
                        cardIconURL: String?,
                        needArrow: Bool,
                        action: @escaping Action) {
        cardsDidTap = action
        models.append(PaymentModel(cardName: cardName, cardInfo: cardInfo, cardIconURL: cardIconURL, needArrow: needArrow, type: .cards))
        models.append(.init(cardName: "Плати частями", cardInfo: "Оформлять", needArrow: needArrow, type: .parts))
        collectionView.reloadData()
    }
    
    private func setupUI() {
        logoImageView.add(toSuperview: view)
        
        cancelButton
            .add(toSuperview: view)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .bottomMargin, usingRelation: .lessThanOrEqual)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .height(.defaultButtonHeight)
        
        payButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.bottom, toEdge: .top, ofView: cancelButton, withInset: .buttonsMargin)
        
        collectionView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.bottom, toEdge: .top, ofView: payButton, withInset: .topMargin)
        
        purchaseInfoStack
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .touchEdge(.right, toEdge: .left, ofView: logoImageView, withInset: .margin)
            .touchEdge(.bottom, toEdge: .top, ofView: collectionView, withInset: .buttonsMargin)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImage, withInset: .topMargin)
            .height(.cartWidth)
        
        logoImageView
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .centerInView(purchaseInfoStack, axis: .y)
            .size(.init(width: .cartWidth, height: .cartWidth))
    }
}

extension PaymentVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.isEmpty ? 2 : models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: CardInfoView.reuseID, for: indexPath) as? CardInfoView else {
            return UICollectionViewCell()
        }
        if models[safe: indexPath.row] != nil {
            let model = models[indexPath.row]
            cell.config(with: model.cardName, cardInfo: model.cardInfo, cardIconURL: model.cardIconURL, needArrow: model.needArrow)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = models[safe: indexPath.row] else { return }
        switch model.type {
        case .cards:
            cardsDidTap?()
        case .parts:
            break
        }
    }
}
