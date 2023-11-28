//
//  PaymentViewBuilder.swift
//  SPaySdk
//
//  Created by Арсений on 30.06.2023.
//

import UIKit

final class PaymentViewBuilder {
    private var payButtonDidTap: Action
    private var cancelButtonDidTap: Action
    private var profileButtonDidTap: Action
    private var featureCount: Int
    
    private(set) lazy var payButton: PaymentButton = {
        let view = PaymentButton()
        view.tapAction = payButtonDidTap
        return view
    }()

    private(set) lazy var cancelButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
        view.setTitle(String(stringLiteral: Cost.Button.Cancel.title), for: .normal)
        view.addAction(cancelButtonDidTap)
        return view
    }()
    
    private(set) lazy var shopLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Shop.font
        view.textColor = Cost.Label.Shop.textColor
        return view
    }()
    
    private(set) lazy var profileButton: ActionButton = {
        let view = ActionButton()
        view.addAction(profileButtonDidTap)
        view.setImage(Asset.user.image, for: .normal)
        return view
    }()
    
    private(set) lazy var costLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Cost.font
        view.textColor = Cost.Label.Cost.textColor
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
    
    private lazy var purchaseInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(shopLabel)
        view.addArrangedSubview(costLabel)
        return view
    }()
    
    private lazy var sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
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
        return collectionView
    }()
    
    init(featureCount: Int,
         profileButtonDidTap: @escaping Action,
         payButtonDidTap: @escaping Action,
         cancelButtonDidTap: @escaping Action) {
        self.featureCount = featureCount
        self.payButtonDidTap = payButtonDidTap
        self.profileButtonDidTap = profileButtonDidTap
        self.cancelButtonDidTap = cancelButtonDidTap
    }
    
    func setupUI(view: UIView) {
        logoImageView.add(toSuperview: view)
        
        cancelButton
            .add(toSuperview: view)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Cost.Button.Cancel.bottom, usingRelation: .equal)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Cancel.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Cancel.right)
            .height(.defaultButtonHeight)
        
        payButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Pay.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Pay.right)
            .touchEdge(.bottom, toEdge: .top, ofView: cancelButton, withInset: Cost.Button.Pay.bottom)
        
        collectionView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.CollectionView.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.CollectionView.right)
            .touchEdge(.bottom, toEdge: .top, ofView: payButton, withInset: Cost.CollectionView.bottom)
        
        logoImageView
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.ImageView.left)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: Cost.ImageView.top)
            .size(Cost.ImageView.size)
        
        profileButton
            .add(toSuperview: view)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.ProfileButton.left)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: Cost.ProfileButton.top)
            .size(Cost.ProfileButton.size)
        
        purchaseInfoStack
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImageView, withInset: Cost.Stack.top)
    }
}

private extension PaymentViewBuilder {
    enum Cost {
        static let sideOffSet: CGFloat = 32.0
        static let height = 56.0
        
        enum Button {
            static let height = Cost.height

            enum Pay {
                static let title = Strings.Pay.title
                static let bottom: CGFloat = 10.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = Cost.sideOffSet
            }
            
            enum Cancel {
                static let title = Strings.Cancel.title
                static let bottom: CGFloat = 44.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = Cost.sideOffSet
            }
        }
        
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
            static let bottom: CGFloat = 22.0
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = Cost.sideOffSet
        }
        
        enum Stack {
            static let bottom: CGFloat = 104.0
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 16.0
            static let height: CGFloat = Cost.height
        }
    }
}
