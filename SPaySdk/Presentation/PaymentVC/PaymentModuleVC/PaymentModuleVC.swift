//
//  PaymentModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import UIKit

final class PaymentModuleVC: UIViewController {
    
    private var presenter: PaymentPresenting
    
    private lazy var viewBuilder = PaymentModuleViewBuilder(featureCount: presenter.featureCount,
                                                            needPayButton: presenter.payButtonText != nil,
                                                            payButtonDidTap: {
        self.presenter.payButtonTapped()
    },
                                                            cancelButtonDidTap: {
        self.presenter.cancelTapped()
    })
                                                                 
    private var dataSource: UICollectionViewDiffableDataSource<PaymentSection, Int>?
    
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
        viewBuilder.setupUI(view: view)
        
        viewBuilder.payButton.setPayTitle(presenter.payButtonText)
    }
    
    func addSnapShot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<PaymentSection, Int>()
        snapshot.appendSections(PaymentSection.allCases)
        print(snapshot.numberOfSections)
        PaymentSection.allCases.forEach { section in
            snapshot.appendItems(presenter.identifiresForPaymentSection(section), toSection: section)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func setHint(with text: String) {
        
        viewBuilder.hintsStackView.add(text)
    }

    func setHints(with texts: [String]) {
        
        viewBuilder.hintsStackView.setStack(texts)
    }
    
    func reloadData() {
        
        guard var newSnapshot = dataSource?.snapshot() else { return }
        newSnapshot.reloadSections(PaymentSection.allCases)
        dataSource?.apply(newSnapshot)
    }
    
    private func configDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<PaymentSection, Int>(collectionView: viewBuilder.collectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            _: Int
        ) -> UICollectionViewCell? in
            guard let section = PaymentSection(rawValue: indexPath.section) else { return nil }
            guard let model = self.presenter.paymentModel(for: indexPath) else { return nil }
            switch section {
            case .features:
                
                if self.presenter.featureCount > 1 {
                    return UICollectionView.config(collectionView: collectionView,
                                                   cellType: SquarePaymentFeatureCell.self,
                                                   with: model,
                                                   fot: indexPath)
                } else {
                    return UICollectionView.config(collectionView: collectionView,
                                                   cellType: BlockPaymentFeatureCell.self,
                                                   with: model,
                                                   fot: indexPath)
                }
            case .card:
                
                return UICollectionView.config(collectionView: collectionView,
                                               cellType: PaymentCardCell.self,
                                               with: model,
                                               fot: indexPath)
            }
        }
    }
    
    private func featureCellType() -> (SelfReusable & SelfConfigCell).Type {
        
        presenter.featureCount > 1 ? SquarePaymentFeatureCell.self : BlockPaymentFeatureCell.self
    }
}

extension PaymentModuleVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectPaymentItem(at: indexPath)
    }
}
