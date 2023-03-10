//
//  PaymentVC.swift
//  SberPaySDK
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
}

protocol IPaymentVC {
    func configShopInfo(with shop: String, cost: String)
    func configCardView(with cardName: String,
                        cardInfo: String,
                        cardIconURL: String?,
                        needArrow: Bool,
                        action: @escaping Action)
}

final class PaymentVC: ContentVC, IPaymentVC {
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
        view.image = .Payment.cart
        return view
    }()
    
    private lazy var purchaseInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(shopLabel)
        view.addArrangedSubview(costLabel)
        return view
    }()

    private lazy var cardInfoView = CardInfoView()
    
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
        
        ImageDownloader.shared.downloadImage(with: "https://cms-res.online.sberbank.ru/sberpay/icons/980000084093.png",
                                             completionHandler: { image, _ in
            self.logoImageView.image = image
        },
                                             placeholderImage: .Payment.cart)
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
    
    func configShopInfo(with shop: String, cost: String) {
        shopLabel.text = shop
        costLabel.text = cost
    }
    
    func configCardView(with cardName: String,
                        cardInfo: String,
                        cardIconURL: String?,
                        needArrow: Bool,
                        action: @escaping Action) {
        cardInfoView.config(with: cardName,
                            cardInfo: cardInfo,
                            cardIconURL: cardIconURL,
                            needArrow: needArrow,
                            action: action)
    }
    
    private func setupUI() {
        view.addSubview(cancelButton)
        view.addSubview(payButton)
        view.addSubview(logoImageView)
        view.addSubview(purchaseInfoStack)
        view.addSubview(cardInfoView)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.bottomMargin),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
        ])
        
        payButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            payButton.heightAnchor.constraint(equalToConstant: .defaultButtonHeight),
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            payButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -.buttonsMargin)
        ])
        
        cardInfoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            cardInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            cardInfoView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -.topMargin)
        ])
        
        purchaseInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            purchaseInfoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            purchaseInfoStack.trailingAnchor.constraint(equalTo: logoImageView.leadingAnchor, constant: -.margin),
            purchaseInfoStack.bottomAnchor.constraint(equalTo: cardInfoView.topAnchor, constant: -.buttonsMargin),
            purchaseInfoStack.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: .topMargin),
            purchaseInfoStack.heightAnchor.constraint(equalToConstant: .cartWidth)
        ])
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            logoImageView.centerYAnchor.constraint(equalTo: purchaseInfoStack.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: .cartWidth),
            logoImageView.heightAnchor.constraint(equalToConstant: .cartWidth)
        ])
    }
}
