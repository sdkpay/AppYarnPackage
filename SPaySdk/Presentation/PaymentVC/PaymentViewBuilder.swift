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
    
    private(set) lazy var payButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(String(stringLiteral: Cost.Button.Pay.title), for: .normal)
        view.addAction(payButtonDidTap)
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
    
    private(set) lazy var costLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Cost.font
        view.textColor = Cost.Label.Cost.textColor
        return view
    }()
    
    private(set) lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var purchaseInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(shopLabel)
        view.addArrangedSubview(costLabel)
        return view
    }()
    
    private(set) lazy var collectionView: CompactCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(
            width: Cost.CollectionView.width,
            height: Cost.CollectionView.itemHeight
        )
        layout.minimumLineSpacing = Cost.CollectionView.minimumLineSpacing
        let collectionView = CompactCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CardInfoView.self, forCellWithReuseIdentifier: CardInfoView.reuseID)
        return collectionView
    }()
    
    init(payButtonDidTap: @escaping Action, cancelButtonDidTap: @escaping Action) {
        self.payButtonDidTap = payButtonDidTap
        self.cancelButtonDidTap = cancelButtonDidTap
    }
    
    func setupUI(view: UIView, logoImage: UIView) {
        logoImageView.add(toSuperview: view)
        
        cancelButton
            .add(toSuperview: view)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Cost.Button.Cancel.bottom, usingRelation: .lessThanOrEqual)
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
        
        purchaseInfoStack
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toEdge: .left, ofView: logoImageView, withInset: Cost.Stack.right)
            .touchEdge(.bottom, toEdge: .top, ofView: collectionView, withInset: Cost.Stack.bottom)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImage, withInset: Cost.Stack.top)
            .height(Cost.Stack.height)
        
        logoImageView
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.ImageView.right)
            .centerInView(purchaseInfoStack, axis: .y, withOffset: Cost.ImageView.yOffSet)
            .size(Cost.ImageView.size)
    }

}

private extension PaymentViewBuilder {
    enum Cost {
        static let sideOffSet: CGFloat = 16.0
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
            static let size: CGSize = .init(width: 56, height: 56)
            static let right: CGFloat = Cost.sideOffSet
            static let yOffSet: CGFloat = -6.0
        }
        
        enum CollectionView {
            static let itemHeight: CGFloat = 72.0
            static let width: CGFloat = UIScreen.main.bounds.width - (16 * 2)
            static let minimumLineSpacing: CGFloat = 8.0
            static let bottom: CGFloat = 22.0
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = Cost.sideOffSet
        }
        
        enum Stack {
            static let bottom: CGFloat = 10.0
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 22.0
            static let height: CGFloat = Cost.height
        }
    }
}
