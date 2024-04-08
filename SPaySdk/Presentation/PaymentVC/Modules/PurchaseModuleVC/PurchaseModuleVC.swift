//
//  PurchaseModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import UIKit

protocol IPurchaseModuleVC {
    
    func showPartsView(_ value: Bool)
    func configBonusesView(_ bonuses: String?)
    func addSnapShot()
    func reloadData()
}

final class PurchaseModuleVC: ModuleVC, IPurchaseModuleVC {
    
    private var presenter: PurchaseModulePresenting
    
    private lazy var viewBuilder = PurchaseViewBuilder(levelsCount: presenter.levelsCount,
                                                       visibleItemsInvalidationHandler: { [weak self] visibleItems, location, _ in
        
        self?.updateLevelIfNeed(items: visibleItems, location: location)
    })

    private var dataSource: UICollectionViewDiffableDataSource<PurchaseSection, Int>?
    
    init(_ presenter: PurchaseModulePresenting) {
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
        viewBuilder.setupUI(view: view)
        addSnapShot()
    }
    
    func addSnapShot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<PurchaseSection, Int>()
        snapshot.appendSections(PurchaseSection.allCases)
        snapshot.appendItems(presenter.identifiresForPurchaseSection())
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadData() {
        
        guard var newSnapshot = dataSource?.snapshot() else { return }
        newSnapshot.reloadSections(PurchaseSection.allCases)
        newSnapshot.reloadItems(presenter.identifiresForPurchaseSection())
        dataSource?.apply(newSnapshot)
    }
    
    func showPartsView(_ value: Bool) {
        
        viewBuilder.changeBonusesViewPosition(withLevelView: value)
        UIView.animate(withDuration: 0.25) {
            self.viewBuilder.levelsView.alpha = value ? 1.0 : 0.0
        }
    }
    
    func configBonusesView(_ bonuses: String?) {
        if let bonuses = bonuses {
            viewBuilder.bonusesView.config(with: bonuses)
        } else {
            viewBuilder.bonusesView.alpha = 0.0
        }
    }
    
    private func showLevel(_ index: Int) {
        
        viewBuilder.levelsView.selectView(at: index)
    }
    
    private func updateLevelIfNeed(items: [NSCollectionLayoutVisibleItem], location: CGPoint) {
        
        guard let index = items.last?.indexPath.row else { return }
        
        let width = viewBuilder.purchaseCollectionView.bounds.width
        let scrollOffset = location.x
        let modulo = scrollOffset.truncatingRemainder(dividingBy: width)
        let tolerance = width / 2
        
        if modulo < tolerance {
            self.showLevel(index)
        }
    }
    
    private func configDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<PurchaseSection, Int>(collectionView: viewBuilder.purchaseCollectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            _: Int
        ) -> UICollectionViewCell? in
            guard let model = self.presenter.purchaseModel(for: indexPath) else { return nil }
            return UICollectionView.config(collectionView: collectionView,
                                           cellType: PurchaseCell.self,
                                           with: model,
                                           fot: indexPath)
        }
    }
}
