//
//  PurchaseModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import UIKit

final class PurchaseModuleVC: UIViewController {
    
    var profileButtonDidTap: Action
    
    private(set) lazy var shopLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Shop.font
        view.textColor = Cost.Label.Shop.textColor
        return view
    }()
    
    private(set) lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.borderColor = Asset.grayDisabled.color.cgColor
        view.layer.borderWidth = Cost.ImageView.border
        view.layer.cornerRadius = Cost.ImageView.radius
        return view
    }()
    
    private(set) lazy var levelsView: LevelsView = {
        let view = LevelsView(frame: .zero)
        view.setup(levelsCount: 4, selectedViewIndex: 0)
        return view
    }()
    
    private lazy var purchaseSectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
        sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
        let section = PurchaseSectionLayoutManager.getSectionLayout(layoutEnvironment: layoutEnvironment)
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
    
    init(profileButtonDidTap: @escaping Action) {
        self.profileButtonDidTap = profileButtonDidTap
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func configShopInfo(with shop: String,
                        iconURL: String?) {
        
        shopLabel.text = shop
        logoImageView.downloadImage(from: iconURL, placeholder: .Payment.cart)
    }
    
    func setupUI() {
        
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
        
        purchaseCollectionView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toEdge: .bottom, ofView: shopLabel, withInset: Cost.Stack.topCost)
        
        levelsView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.top, toEdge: .bottom, ofView: purchaseCollectionView, withInset: Cost.Stack.topCost)
    }
}

private extension PurchaseModuleVC {
    enum Cost {
        static let sideOffSet: CGFloat = 32.0
        static let height = 56.0

        enum Label {
            enum Shop {
                static let font = UIFont.bodi2
                static let textColor = UIColor.textSecondary
            }
            
            enum Cost {
                static let font = UIFont.header
                static let textColor = UIColor.textPrimory
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
            static let itemHeight: CGFloat = 72.0
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
