//
//  PaymentVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

protocol IPaymentVC {
    func configShopInfo(with shop: String, cost: String, fullPrice: String?, iconURL: String?)
    func setPayButtonTitle(title: String)
    func reloadCollectionView()
}

final class PaymentVC: ContentVC, IPaymentVC {
    private lazy var viewBuilder = PaymentViewBuilder { [weak self] in
        guard let self = self else { return }
        self.presenter.payButtonTapped()
    } cancelButtonDidTap: { [weak self] in
        guard let self = self else { return }
        self.presenter.cancelTapped()
    }

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
        viewBuilder.setupUI(view: view, logoImage: logoImage)
        viewBuilder.collectionView.delegate = self
        viewBuilder.collectionView.dataSource = self
        presenter.viewDidLoad()
        SBLogger.log(.didLoad(view: self))
        profileView.addAction {
            self.presenter.openProfile()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
    }
    
    func configShopInfo(with shop: String, cost: String, fullPrice: String?, iconURL: String?) {
        viewBuilder.shopLabel.text = shop
        viewBuilder.logoImageView.downloadImage(from: iconURL, placeholder: .Payment.cart)
        if let fullPrice {
            let price: String = cost + Strings.From.title(fullPrice)
            let attributedPrice = NSAttributedString(text: price,
                                                     dedicatedPart: Strings.From.title(fullPrice),
                                                     attrebutes: [
                                                        .font: UIFont.bodi3 ?? .systemFont(ofSize: 15),
                                                        .foregroundColor: UIColor.textSecondary
                                                     ])
            viewBuilder.costLabel.text = nil
            viewBuilder.costLabel.attributedText = attributedPrice
        } else {
            viewBuilder.costLabel.attributedText = nil
            viewBuilder.costLabel.text = cost
        }
    }
    
    func setPayButtonTitle(title: String) {
        viewBuilder.payButton.setTitle(title, for: .normal)
    }
    
    func reloadCollectionView() {
        viewBuilder.collectionView.reloadData()
    }
}

extension PaymentVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.cellDataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: CardInfoView.reuseID, for: indexPath) as? CardInfoView else {
            return UICollectionViewCell()
        }
        let model = presenter.model(for: indexPath)
        cell.config(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
}
