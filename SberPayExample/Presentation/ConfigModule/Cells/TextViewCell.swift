//
//  TextViewCell.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SBLayout

extension CGFloat {
    static let sideMargin = 5.0
}

private extension CGFloat {
    static let topMargin = 5.0
    static let height = 50.0
}

final class TextViewCell: UITableViewCell {
    static var reuseID: String { "TextViewCell" }

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
        if #available(iOS 13.0, *) {
            view.setImage(UIImage(systemName: "goforward"), for: .normal)
        }
        view.tintColor = .lightGray
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 7
        view.addAction {
            self.refreshButtonTapped?()
        }
        return view
    }()
    
    private var refreshButtonTapped: (() -> Void)?
    private var textEdited: ((String) -> Void)?

    func config(title: String,
                text: String?,
                placeholder: String? = nil,
                keyboardType: UIKeyboardType = .default,
                description: String? = nil,
                refreshButtonAvaliable: Bool = false,
                needRefreshButton: Bool = false,
                maxLength: Int? = nil,
                textEdited: @escaping (String) -> Void,
                refreshButtonTapped: (() -> Void)? = nil) {
        titleLabel.text = title
        textField.text = text
        self.textEdited = textEdited
        
        if let placeholder {
            textField.placeholder = placeholder
        } else {
            textField.placeholder = title
        }
        setupUI(with: needRefreshButton)
        contentView.backgroundColor = .clear
    }
    
    private func setupUI(with needRefreshButton: Bool) {
        titleLabel
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.left, ofView: contentView, withInset: .sideMargin)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        textField
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.right, ofView: titleLabel, withInset: .sideMargin)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView)
    }
}
