//
//  HintView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.12.2023.
//

import UIKit

private extension CGFloat {
    static let buttonWidth = 24.0
    static let rightMargin = 20.0
}

final class HintView: SwipableView {
    
    var closeAction: Action?
    
    private lazy var textLabel: UILabel = {
        let view = UILabel()
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
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
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
        
        stackView
            .add(toSuperview: self)
            .touchEdgesToSuperview([.bottom, .top, .left])
            .touchEdge(.right, toSameEdgeOfView: self, withInset: .rightMargin)
    }
}
