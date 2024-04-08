//
//  HintsStackView.swift
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
    static let buttonTop = 2.0
    static let titleTop = 5.0
}

private final class HintView: SwipableView {
    
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
        view.setImage(Asset.Image.cross.image, for: .normal)
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
    
    override init() {
        super.init()
        
        viewDismissAction = {
            self.closeAction?()
        }
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with text: String) {
        textLabel.text = text
    }
    
    private func closeTapped() {
        
        UIView.animate(withDuration: 0.25,
                       animations: {
            self.alpha = 0
        }, completion: { _ in
            self.closeAction?()
        })
    }
    
    private func setupUI() {
        
        closeButton
            .add(toSuperview: self)
            .touchEdge(.right, toSameEdgeOfView: self, withInset: .rightMargin)
            .touchEdge(.top, toSameEdgeOfView: self, withInset: .buttonTop)
        
        textLabel
            .add(toSuperview: self)
            .touchEdge(.right, toEdge: .left, ofView: closeButton, withInset: .spacing)
            .touchEdge(.top, toSameEdgeOfView: self, withInset: .titleTop)
            .touchEdge(.bottom, toSameEdgeOfView: self)
        
        hintStickView
            .add(toSuperview: self)
            .touchEdge(.left, toSameEdgeOfView: self)
            .touchEdge(.right, toEdge: .left, ofView: textLabel, withInset: .spacing)
            .centerInView(closeButton, axis: .y)
    }
}

final class HintsStackView: UIView {
    
    private var hintsStack = [String]()
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(_ hint: String) {
        
        hintsStack.append(hint)
    }
    
    func setStack(_ hints: [String]) {
        
        hintsStack = hints
        
        subviews.forEach({ $0.removeFromSuperview() })
        show()
    }
    
    func show() {
        
        if let hint = hintsStack.last {
            
            hintsStack.removeLast()
            showHintView(with: hint)
        }
    }
    
    private func showHintView(with text: String) {
        
        let hint = HintView()
        hint.alpha = 0
        hint.setup(with: text)
        
        hint.closeAction = {
            
            hint.removeFromSuperview()
            self.show()
        }

        hint
            .add(toSuperview: self)
            .touchEdge(.top, toEdge: .top, ofView: self)
            .touchEdge(.bottom, toEdge: .bottom, ofView: self)
            .touchEdge(.left, toEdge: .left, ofView: self)
            .touchEdge(.right, toEdge: .right, ofView: self)
        
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.25) {
            hint.alpha = 1
        }
    }
}
