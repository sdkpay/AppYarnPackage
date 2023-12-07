//
//  PurchaseSwappableView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 06.12.2023.
//

import UIKit

final class PurchaseSwappableView: UIView {
    
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
    
    private(set) lazy var partInfoLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Cost.font
        view.textColor = Cost.Label.Cost.textColor
        return view
    }()
    
    private lazy var purchaseInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(shopLabel)
        view.addArrangedSubview(costLabel)
        view.addArrangedSubview(partInfoLabel)
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        purchaseInfoStack
            .add(toSuperview: self)
            .touchEdgesToSuperview([.top, .bottom, .left, .right])
    }

}

private extension PurchaseSwappableView {
    
    enum Cost {
        
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
    }
}
