//
//  PaymentVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

protocol IPaymentVC {
    func configShopInfo(with shop: String, cost: String, fullPrice: String?, iconURL: String?)
    func addSnapShot()
    func configHint(with text: String)
    func reloadData()
}

final class PaymentVC: ContentVC, IPaymentVC {

    private lazy var viewBuilder = PaymentViewBuilder(featureCount: presenter.featureCount,
                                                      profileButtonDidTap: { [weak self] in
        guard let self = self else { return }
        self.presenter.profileTapped()
    }, payButtonDidTap: { [weak self] in
        guard let self = self else { return }
        self.presenter.payButtonTapped()
    }, cancelButtonDidTap: { [weak self] in
        guard let self = self else { return }
        self.presenter.cancelTapped()
    })
    
    private var dataSource: UICollectionViewDiffableDataSource<PaymentSection, Int>?

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
        configDataSource()
        viewBuilder.collectionView.delegate = self
        presenter.viewDidLoad()
        viewBuilder.setupUI(view: view, needHint: presenter.needHint)
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideLoading(animate: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
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
    
    func reloadData() {
        
        guard var newSnapshot = dataSource?.snapshot() else { return }
        newSnapshot.reloadSections(PaymentSection.allCases)
        dataSource?.apply(newSnapshot)
    }
    
    func addSnapShot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<PaymentSection, Int>()
        snapshot.appendSections(PaymentSection.allCases)
        print(snapshot.numberOfSections)
        PaymentSection.allCases.forEach { section in
            snapshot.appendItems(presenter.identifiresForSection(section), toSection: section)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func configHint(with text: String) {
        
        viewBuilder.hintView.setup(with: text)
    }
    
    private func configDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<PaymentSection, Int>(collectionView: viewBuilder.collectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            _: Int
        ) -> UICollectionViewCell? in
            guard let section = PaymentSection(rawValue: indexPath.section) else { return nil }
            guard let model = self.presenter.model(for: indexPath) else { return nil }
            switch section {
            case .features:
                return self.config(collectionView: collectionView,
                                   cellType: BlockPaymentFeatureCell.self,
                                   with: model,
                                   fot: indexPath)
            case .card:
                return self.config(collectionView: collectionView,
                                   cellType: PaymentCardCell.self,
                                   with: model,
                                   fot: indexPath)
            }
        }
    }
    
    private func config<T: SelfReusable & SelfConfigCell, U: AbstractCellModel>(collectionView: UICollectionView,
                                                                                cellType: T.Type,
                                                                                with model: U,
                                                                                fot indexPath: IndexPath) -> T? {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else { return nil }
        cell.config(with: model)
        return cell
    }
}

extension PaymentVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
}
