//
//  PurchaseViewBuilder.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 09.12.2023.
//

import UIKit

final class PurchaseViewBuilder {
    
    private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler

    private(set) lazy var levelsView: LevelsView = {
        let view = LevelsView(frame: .zero)
        view.alpha = 0
        view.setup(levelsCount: levelsCount, selectedViewIndex: 0)
        return view
    }()
    
    private lazy var purchaseSectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
        _, layoutEnvironment -> NSCollectionLayoutSection? in
        let section = PurchaseSectionLayoutManager.getSectionLayout(layoutEnvironment: layoutEnvironment)
        section.visibleItemsInvalidationHandler = self.visibleItemsInvalidationHandler
        return section
    }
    
    private(set) lazy var purchaseCollectionView: CompactCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = CompactCollectionView(frame: .zero,
                                                   collectionViewLayout: PurchaseCollectionViewLayoutManager.create(with: purchaseSectionProvider))
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PurchaseCell.self, forCellWithReuseIdentifier: PurchaseCell.reuseId)
        return collectionView
    }()
    
    private var levelsCount: Int
    
    init(levelsCount: Int,
         visibleItemsInvalidationHandler: @escaping NSCollectionLayoutSectionVisibleItemsInvalidationHandler) {
        self.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        self.levelsCount = levelsCount
    }
    
    func setupUI(view: UIView) {
        
        purchaseCollectionView
            .add(toSuperview: view)
            .height(Cost.CollectionView.itemHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .width(Cost.CollectionView.itemWidth)
            .touchEdge(.top, toEdge: .top, ofView: view, withInset: Cost.Stack.topCost)
        
        levelsView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.top, toEdge: .bottom, ofView: purchaseCollectionView, withInset: Cost.Stack.topCost)
    }
}

private extension PurchaseViewBuilder {
    
    enum Cost {
        
        static let sideOffSet: CGFloat = 32.0
        static let height = 56.0
        
        enum CollectionView {
            static let itemHeight: CGFloat = 68.0
            static let itemWidth: CGFloat = UIScreen.main.bounds.width * 0.6
            static let minimumLineSpacing: CGFloat = 8.0
            static let bottom: CGFloat = 20.0
            static let bottomToCancel: CGFloat = 8.0
            static let right: CGFloat = 16.0
            static let left: CGFloat = 16.0
            static let top: CGFloat = Cost.sideOffSet
        }
        
        enum Stack {
            static let bottom: CGFloat = 104.0
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 16.0
            static let topCost: CGFloat = 4.0
            static let height: CGFloat = Cost.height
        }
    }
}
