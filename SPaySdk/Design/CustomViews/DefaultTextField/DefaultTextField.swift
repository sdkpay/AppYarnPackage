//
//  DefaultTextField.swift
//  SPaySdk
//
//  Created by Арсений on 03.08.2023.
//

import UIKit

enum TextFieldState {
    case selected
    case empty
    
    var color: UIColor {
        switch self {
        case .empty:
            return .systemRed.withAlphaComponent(0.7)
        case .selected:
            return .gray
        }
    }
}

private extension CGFloat {
    static let backMargin = 4.0
    static let alertMargin = 20.0
    static let height = 50.0
    static let buttonHeight = 45.0
}

final class DefaultTextField: UIView {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.borderColor = ColorAsset.Color.backgroundPrimary.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 7
        return view
    }()

    private lazy var textField: InsertTextField = {
        let view = InsertTextField()
        view.borderStyle = .none
        view.textAlignment = .left
        view.clearButtonMode = .whileEditing
        view.placeholder = "Код подтверждения"
        view.addTarget(self, action: #selector(editingBegin), for: .editingDidBegin)
        view.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        view.addTarget(self, action: #selector(valueChanged), for: .allEvents)
        return view
    }()

    private var textEdited: ((String) -> Void)?
    private var textEndEdited: ((String) -> Void)?
    private var maxLength: Int?
    
    func config(maxLength: Int?,
                textEdited: ((String) -> Void)?,
                textEndEdited: @escaping (String) -> Void,
                buttonTapped: (() -> Void)? = nil) {
        self.maxLength = maxLength
        if maxLength != nil {
            valueChanged()
        }
        textField.textContentType = .oneTimeCode
        textField.keyboardType = .numberPad
        self.textEdited = textEdited
        self.textEndEdited = textEndEdited
        setupUI()
    }
    
    func setState(_ state: TextFieldState, animate: Bool = true) {
        UIView.animate(withDuration: animate ? 0.25 : 0.0,
                       delay: .zero,
                       options: .transitionCrossDissolve,
                       animations: {
            self.backgroundView.layer.borderColor = state.color.cgColor
        }, completion: nil)
    }
    
    @objc
    private func editingBegin() {
        setState(.selected)
    }
    
    @objc
    private func editingEnd() {
        setState(.empty)
        textEndEdited?(textField.text ?? "")
    }
    
    @objc
    private func valueChanged() {
        textEdited?(textField.text ?? "")
        guard let maxLength,
              maxLength >= textField.text?.count ?? 0 else {
            return
        }
        textEdited?(textField.text ?? "")
    }
    
    private func setupUI() {
        backgroundView
            .add(toSuperview: self)
            .touchEdge(.top, toEdge: .top, ofView: self, withInset: .backMargin)
            .touchEdge(.left, toEdge: .left, ofView: self, withInset: .backMargin)
            .touchEdge(.right, toEdge: .right, ofView: self, withInset: .backMargin)
            .height(.height)
        
        textField
            .add(toSuperview: backgroundView)
            .touchEdge(.top, toEdge: .top, ofView: backgroundView)
            .touchEdge(.left, toEdge: .left, ofView: backgroundView, withInset: .backMargin)
            .touchEdge(.right, toEdge: .right, ofView: backgroundView, withInset: .backMargin)
            .touchEdge(.bottom, toEdge: .bottom, ofView: backgroundView)
    }
}

final class InsertTextField: UITextField {
    private var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .buttonHeight)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
