//
//  PaymentModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//


import UIKit

protocol IPaymentModuleVC {
    func addSnapShot()
    func configHint(with text: String)
    func showHint(_ value: Bool)
    func reloadData()
}

final class PaymentModuleVC: UIViewController, IPaymentModuleVC {
    
    private var featureCount: Int
    private var needPayButton: Bool
    private var payButtonDidTap: Action
    private var cancelButtonDidTap: Action
    
    
    private lazy var viewBuilder = PaymentModuleViewBuilder(featureCount: featureCount,
                                                            needPayButton: needPayButton,
                                                            payButtonDidTap: payButtonDidTap,
                                                            cancelButtonDidTap: cancelButtonDidTap)
                                                                 
    
    private var dataSource: UICollectionViewDiffableDataSource<PaymentSection, Int>?
    
    init(featureCount: Int, 
         needPayButton: Bool,
         payButtonDidTap: @escaping Action,
         cancelButtonDidTap: @escaping Action) {
        self.featureCount = featureCount
        self.needPayButton = needPayButton
        self.payButtonDidTap = payButtonDidTap
        self.cancelButtonDidTap = cancelButtonDidTap
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func showHint(_ value: Bool) {
        
        UIView.animate(withDuration: 0.25) {
            self.viewBuilder.hintView.alpha = value ? 1.0 : 0.0
        }
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
            guard let model = self.presenter.model(for: indexPath) else { return nil }
            switch section {
            case .features:
                
                if self.presenter.featureCount > 1 {
                    return self.config(collectionView: collectionView,
                                       cellType: SquarePaymentFeatureCell.self,
                                       with: model,
                                       fot: indexPath)
                } else {
                    return self.config(collectionView: collectionView,
                                       cellType: BlockPaymentFeatureCell.self,
                                       with: model,
                                       fot: indexPath)
                }
            case .card:
                
                return self.config(collectionView: collectionView,
                                   cellType: PaymentCardCell.self,
                                   with: model,
                                   fot: indexPath)
            }
        }
    }
    
    private func featureCellType() -> (SelfReusable & SelfConfigCell).Type {
        
        presenter.featureCount > 1 ? SquarePaymentFeatureCell.self : BlockPaymentFeatureCell.self
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

extension PaymentModuleVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
}
