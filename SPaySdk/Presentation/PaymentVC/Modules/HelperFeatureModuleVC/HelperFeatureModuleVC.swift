//
//  HelperFeatureModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

protocol IHelperFeatureModuleVC {
    
    func addSnapShot()
    func reloadData()
}

final class HelperFeatureModuleVC: ModuleVC, IHelperFeatureModuleVC {
    
    private var presenter: HelperFeatureModulePresenting
    
    private lazy var viewBuilder = PaymentFeatureModuleViewBuilder(featureCount: presenter.featureCount)
    
    private var dataSource: UICollectionViewDiffableDataSource<PaymentFeatureSection, Int>?
    
    init(_ presenter: HelperFeatureModulePresenting) {
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
        
        var snapshot = NSDiffableDataSourceSnapshot<PaymentFeatureSection, Int>()
        snapshot.appendSections(PaymentFeatureSection.allCases)
        print(snapshot.numberOfSections)
        PaymentFeatureSection.allCases.forEach { section in
            snapshot.appendItems(presenter.identifiresForSection(section), toSection: section)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    @MainActor
    func reloadData() {
        
        guard var newSnapshot = dataSource?.snapshot() else { return }
        newSnapshot.reloadSections(PaymentFeatureSection.allCases)
        dataSource?.apply(newSnapshot)
    }
    
    private func configDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<PaymentFeatureSection, Int>(collectionView: viewBuilder.collectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            _: Int
        ) -> UICollectionViewCell? in
            guard let model = self.presenter.paymentModel(for: indexPath) else { return nil }
                
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
        }
    }
}

extension HelperFeatureModuleVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectPaymentItem(at: indexPath)
    }
}
