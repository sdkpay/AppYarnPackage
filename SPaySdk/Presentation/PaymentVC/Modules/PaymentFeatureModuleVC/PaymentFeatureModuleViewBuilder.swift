//
//  PaymentFeatureModuleViewBuilder.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import UIKit

final class PaymentFeatureModuleViewBuilder {

    private var featureCount: Int
    
    private(set) lazy var hintsStackView: HintsStackView = {
        let view = HintsStackView()
        return view
    }()

    private lazy var sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
        sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
        guard let sectionKind = PaymentSection(rawValue: sectionIndex) else { return nil }
        let section = PaymentSectionLayoutManager.getSectionLayout(sectionKind, featureCount: self.featureCount, layoutEnvironment: layoutEnvironment)
        return section
    }
    
    private(set) lazy var collectionView: CompactCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = CompactCollectionView(frame: .zero,
                                                   collectionViewLayout: PaymentCollectionViewLayoutManager.create(with: sectionProvider))
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PaymentCardCell.self, forCellWithReuseIdentifier: PaymentCardCell.reuseId)
        collectionView.register(BlockPaymentFeatureCell.self, forCellWithReuseIdentifier: BlockPaymentFeatureCell.reuseId)
        collectionView.register(SquarePaymentFeatureCell.self, forCellWithReuseIdentifier: SquarePaymentFeatureCell.reuseId)
        return collectionView
    }()
    
    init(featureCount: Int) {
        self.featureCount = featureCount
    }
    
    func setupUI(view: UIView) {
    
        collectionView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.CollectionView.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.CollectionView.right)
            .touchEdge(.bottom,
                       toEdge: .bottom,
                       ofView: view)
        
        hintsStackView
            .add(toSuperview: view)
            .touchEdge(.left, toEdge: .left, ofView: view, withInset: Cost.Hint.margin)
            .touchEdge(.right, toEdge: .right, ofView: view, withInset: Cost.Hint.margin)
            .touchEdge(.bottom, toEdge: .top, ofView: collectionView, withInset: Cost.Hint.bottom)
            .height(Cost.height, priority: .defaultLow)
            .touchEdge(.top, toEdge: .top, ofView: view)
    }
}

private extension PaymentFeatureModuleViewBuilder {
    enum Cost {
        static let sideOffSet: CGFloat = 32.0
        static let height = 56.0
        
        enum Hint {
            static let bottom = 20.0
            static let margin = 36.0
        }
        
        enum CollectionView {
            static let itemHeight: CGFloat = 72.0
            static let minimumLineSpacing: CGFloat = 8.0
            static let bottom: CGFloat = 20.0
            static let bottomToCancel: CGFloat = 8.0
            static let right: CGFloat = 16.0
            static let left: CGFloat = 16.0
            static let top: CGFloat = Cost.sideOffSet
        }
    }
}
