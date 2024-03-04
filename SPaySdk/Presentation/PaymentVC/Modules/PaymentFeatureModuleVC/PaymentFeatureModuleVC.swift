//
//  PaymentFeatureModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

protocol IPaymentFeatureModuleVC {
    
    func addSnapShot()
    func reloadData()
}

final class PaymentFeatureModuleVC: ModuleVC, IPaymentFeatureModuleVC {
    
    private var presenter: PaymentFeatureModulePresenting
    
    private lazy var viewBuilder = PaymentFeatureModuleViewBuilder(featureCount: presenter.featureCount)
    
    private var dataSource: UICollectionViewDiffableDataSource<PaymentSection, Int>?
    
    init(_ presenter: PaymentFeatureModulePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDataSource()
        presenter.viewDidLoad()
        viewBuilder.collectionView.delegate = self
        viewBuilder.setupUI(view: view)
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

extension PaymentFeatureModuleVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectPaymentItem(at: indexPath)
    }
}
