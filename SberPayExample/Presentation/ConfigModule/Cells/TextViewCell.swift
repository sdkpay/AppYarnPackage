//
//  TextViewCell.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit

extension CGFloat {
    static let sideMargin = 5.0
}

private extension CGFloat {
    static let topMargin = 5.0
    static let height = 50.0
}

final class TextViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.sizeToFit()
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.borderStyle = .none
        view.textAlignment = .left
        view.clearButtonMode = .whileEditing
        view.font = .systemFont(ofSize: 14)
        view.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        view.addTarget(self, action: #selector(valueChanged), for: .allEvents)
        return view
    }()
    
    @objc
    private func editingEnd() {
        textEdited?(textField.text ?? "")
    }
    
    @objc
    private func valueChanged() {
        textEdited?(textField.text ?? "")
    }

    private lazy var refreshButton: ActionButton = {
        let view = ActionButton()
        view.setImage(UIImage(systemName: "info"), for: .normal)
        view.tintColor = .lightGray
        view.addAction {
            self.infoButtonTapped?()
        }
        return view
    }()
    
    private var infoButtonTapped: (() -> Void)?
    private var textEdited: ((String) -> Void)?

    func config(title: String,
                text: String?,
                accessibilityIdentifier: String? = nil,
                placeholder: String? = nil,
                keyboardType: UIKeyboardType = .default,
                description: String? = nil,
                maxLength: Int? = nil,
                textEdited: @escaping (String) -> Void,
                infoButtonTapped: (() -> Void)? = nil) {
        titleLabel.text = title
        textField.text = text
        textField.accessibilityIdentifier = accessibilityIdentifier
        
        self.textEdited = textEdited
        self.infoButtonTapped = infoButtonTapped
        
        if let placeholder {
            textField.placeholder = placeholder
        } else {
            textField.placeholder = title
        }
        setupUI()
        contentView.backgroundColor = .clear
    }
    
    private func setupUI() {
        
        titleLabel
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.left, ofView: contentView, withInset: .sideMargin)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        if infoButtonTapped != nil {
            
            refreshButton
                .add(toSuperview: contentView)
                .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView)
                .height(40)
                .width(40)
                .centerInSuperview(.y)
        }
        
        textField
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.right, ofView: titleLabel, withInset: .sideMargin)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
        
        if infoButtonTapped != nil {
            textField
                .touchEdge(SBEdge.right, toEdge: SBEdge.left, ofView: refreshButton, withInset: .sideMargin)
        } else {
            textField
                .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView)
        }
    }
}
