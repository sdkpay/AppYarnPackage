//
//  HintView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.12.2023.
//

import UIKit

private extension CGFloat {
    static let spacing = 8.0
    static let topMargin = 15.0
    static let buttonWidth = 24.0
    static let stickWidth = 12.0
    static let stickHeight = 1.5
    static let rightMargin = 20.0
}

final class HintView: SwipableView {
    
    var closeAction: Action?
    
    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .medium2
        view.textColor = .textSecondary
        return view
    }()
    
    private lazy var closeButton: ActionButton = {
        let view = ActionButton()
        view.setImage(Asset.cross.image, for: .normal)
        view.addAction {
            self.closeTapped()
        }
        view.height(.buttonWidth)
        view.width(.buttonWidth)
        return view
    }()
    
    private lazy var hintStickView: UIView = {
        let view = UIView()
        view.height(.stickHeight)
        view.width(.stickWidth)
        view.backgroundColor = .textSecondary
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 10
        view.addArrangedSubview(hintStickView)
        view.addArrangedSubview(textLabel)
        view.addArrangedSubview(closeButton)
        return view
    }()
    
    override init() {
        super.init()
        closeAction = viewDismissAction
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with text: String) {
        textLabel.text = text
    }
    
    private func closeTapped() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
            self.closeAction?()
        }
    }
    
    private func setupUI() {
        
        closeButton
            .add(toSuperview: self)
            .touchEdge(.right, toSameEdgeOfView: self, withInset: .rightMargin)
            .touchEdge(.top, toSameEdgeOfView: self, withInset: .topMargin)
        
        textLabel
            .add(toSuperview: self)
            .touchEdge(.right, toEdge: .left, ofView: closeButton, withInset: .spacing)
            .touchEdge(.top, toSameEdgeOfView: self, withInset: .rightMargin)
            .touchEdge(.bottom, toSameEdgeOfView: self)
        
        hintStickView
            .add(toSuperview: self)
            .touchEdge(.left, toSameEdgeOfView: self)
            .touchEdge(.right, toEdge: .left, ofView: textLabel, withInset: .spacing)
            .centerInView(closeButton, axis: .y)
    }
}
