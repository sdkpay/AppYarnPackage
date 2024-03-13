//
//  PurchaseViewBuilder.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 09.12.2023.
//

import UIKit

final class PurchaseViewBuilder {
    
    private var profileButtonDidTap: Action
    private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler
    
    private var bottomConstraint: NSLayoutConstraint?
    
    private(set) lazy var shopLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Shop.font
        view.textColor = Cost.Label.Shop.textColor
        return view
    }()
    
    private(set) lazy var infoTextLabel: UILabel = {
        let view = UILabel()
        view.font = .header
        view.numberOfLines = 0
        view.textColor = .textPrimory
        return view
    }()
    
    private(set) lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.layer.borderColor = Asset.grayDisabled.color.cgColor
        view.layer.borderWidth = Cost.ImageView.border
        view.layer.cornerRadius = Cost.ImageView.radius
        return view
    }()
    
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
    
    private(set) lazy var profileButton: ActionButton = {
        let view = ActionButton()
        view.addAction(profileButtonDidTap)
        view.setImage(Asset.user.image, for: .normal)
        return view
    }()
    
    private var levelsCount: Int
    
    init(levelsCount: Int,
         needInfoText: Bool,
         visibleItemsInvalidationHandler: @escaping NSCollectionLayoutSectionVisibleItemsInvalidationHandler,
         profileButtonDidTap: @escaping Action) {
        self.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        self.profileButtonDidTap = profileButtonDidTap
        
        self.levelsCount = levelsCount
        
        if needInfoText {
            
            infoTextLabel.alpha = 1.0
            purchaseCollectionView.alpha = 0.0
        } else {
            
            infoTextLabel.alpha = 0.0
            purchaseCollectionView.alpha = 1.0
        }
    }
    
    func changeBottomConstraint(withLevelView: Bool) {
        bottomConstraint?.constant = withLevelView ? -Cost.Stack.bottomWithLevel : Cost.Stack.bottom
    }
    
    func setupUI(view: UIView) {
        logoImageView.add(toSuperview: view)
        
        logoImageView
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.ImageView.left)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: Cost.ImageView.top)
            .size(Cost.ImageView.size)
        
        shopLabel
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImageView, withInset: Cost.Stack.top)
        
        profileButton
            .add(toSuperview: view)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.ProfileButton.left)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: Cost.ProfileButton.top)
            .size(Cost.ProfileButton.size)
        
        infoTextLabel
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Stack.left)
            .touchEdge(.top, toEdge: .bottom, ofView: shopLabel, withInset: Cost.Stack.topCost)
        
        purchaseCollectionView
            .add(toSuperview: view)
            .height(Cost.CollectionView.itemHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .width(Cost.CollectionView.itemWidth)
            .touchEdge(.top, toEdge: .bottom, ofView: shopLabel, withInset: Cost.Stack.topCost)
        bottomConstraint = purchaseCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: Cost.Stack.bottom)
        bottomConstraint?.isActive = true
        
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
     
        enum Label {
            enum Shop {
                static let font = UIFont.medium2
                static let textColor = UIColor.textSecondary
            }
        }
        
        enum ImageView {
            static let size: CGSize = .init(width: 52, height: 52)
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 36.0
            static let radius: CGFloat = 16.0
            static let border: CGFloat = 1.0
        }
        
        enum ProfileButton {
            static let size: CGSize = .init(width: 32, height: 32)
            static let top: CGFloat = 36.0
            static let left: CGFloat = Cost.sideOffSet
        }
        
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
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 16.0
            static let topCost: CGFloat = 4.0
            static let height: CGFloat = Cost.height
            static let bottomWithLevel: CGFloat = 15.0
            static let bottom: CGFloat = 5.0
        }
    }
}
