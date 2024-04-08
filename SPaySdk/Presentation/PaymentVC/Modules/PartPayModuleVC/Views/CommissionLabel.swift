//
//  CommissionLabel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.03.2024.
//

import UIKit

private extension CGFloat {
    static let titleVertical = 6.0
    static let titleLeft = 8.0
    static let titleHeight = 16.0
    static let imageLeft = 4.0
    static let imageInset = 8.0
    static let cornerRadius = 8.0
}

final class CommissionLabel: UIView {

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium2
        view.numberOfLines = 0
        view.textColor = .textPrimory
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with commission: Int) {
        
        titleLabel.text = Strings.PartPay.Commission.title(commission.price(.RUB))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topRight, .bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: .cornerRadius,
                                                    height: .cornerRadius))

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    private func setupUI() {
        
        layer.cornerRadius = 2
        
        switch traitCollection.userInterfaceStyle {
            
        case .unspecified, .light:
            applyBlurEffect(style: .systemUltraThinMaterialDark, alphaValue: 0.24)
        case .dark:
            applyBlurEffect(style: .systemUltraThinMaterial)
        @unknown default:
            applyBlurEffect(style: .systemUltraThinMaterialDark, alphaValue: 0.24)
        }
        
        titleLabel
            .add(toSuperview: self)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .titleVertical)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .titleLeft)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .titleLeft)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .titleVertical)
    }
}
