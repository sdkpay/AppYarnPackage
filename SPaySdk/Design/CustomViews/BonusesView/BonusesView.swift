//
//  BonusesView.swift
//  SPaySdk
//
//  Created by Серёгин Михаил Алексеевич on 04.03.2024.
//

import UIKit

private extension CGFloat {
    static let titleVertical = 5.0
    static let titleLeft = 6.0
    static let titleHeight = 16.0
    static let imageLeft = 4.0
    static let imageInset = 8.0
    static let cornerRadius = 8.0
}

final class BonusesView: UIView {

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium2
        view.numberOfLines = 0
        view.textColor = .backgroundPrimary
        return view
    }()
    
    private lazy var imageView = UIImageView(image: Asset.sbsp.image)
    
    private var checkTapped: BoolAction?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with text: String?) {
        if let text = text, !text.isEmpty {
            titleLabel.text = "+\(text)"
            alpha = 1
        } else {
            alpha = 0
        }
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
        
        overrideUserInterfaceStyle = .light
        
        backgroundColor = Asset.greenPrimary.color
        layer.cornerRadius = 2
        titleLabel
            .add(toSuperview: self)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .titleVertical)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .titleLeft)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .titleVertical)
            .height(.equal, to: .titleHeight)
        
        imageView
            .add(toSuperview: self)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .imageInset)
            .touchEdge(.left, toEdge: .right, ofView: titleLabel, withInset: .imageLeft)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .imageInset)
    }
}
