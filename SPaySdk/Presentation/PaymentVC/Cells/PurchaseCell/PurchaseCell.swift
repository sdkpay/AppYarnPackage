//
//  PurchaseCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import UIKit

private extension CGFloat {
    static let arrowWidth = 24.0
    static let cardWidth = 36.0
    static let letterSpacing = -0.4
}

final class PurchaseCell: UICollectionViewCell, SelfReusable, SelfConfigCell {
    
    private lazy var costLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Cost.font
        view.textColor = Cost.Label.Cost.textColor
        return view
    }()
    
    private lazy var partInfoLabel: UILabel = {
        let view = UILabel()
        view.font = Cost.Label.Part.font
        view.textColor = Cost.Label.Part.textColor
        return view
    }()
    
    private lazy var purchaseInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(costLabel)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config<U>(with model: U) where U: AbstractCellModel {
        
        guard let model = model.map(type: PurchaseModel.self) else { return }
        costLabel.text = model.title
        
        if model.subTitle != nil {
            purchaseInfoStack.addArrangedSubview(partInfoLabel)
        }
        
        partInfoLabel.text = model.subTitle
        setupUI()
    }
    
    private func setupUI() {
        
        purchaseInfoStack
            .add(toSuperview: self)
            .touchEdgesToSuperview([.top, .bottom, .left, .right])
    }
}

private extension PurchaseCell {
    
    enum Cost {
        
        enum Label {
            enum Part {
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
