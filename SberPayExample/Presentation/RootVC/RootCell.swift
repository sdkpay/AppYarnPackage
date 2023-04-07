//
//  RootCell.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 09.11.2022.
//

import UIKit

private extension CGFloat {
    static let topMargin = 15.0
    static let sideMargin = 20.0
}

final class RootCell: UITableViewCell {
    static var reuseID: String { "RootCell" }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.textColor = .black
        view.backgroundColor = .white
        view.borderStyle = .roundedRect
        view.clearButtonMode = .whileEditing
        view.font = UIFont.systemFont(ofSize: 16)
        view.addTarget(self, action: #selector(textChanged), for: .allEditingEvents)
        return view
    }()
    
    private lazy var refreshButton: UIButton = {
        let view = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            view.setImage(UIImage(systemName: "goforward"), for: .normal)
        }
        view.addTarget(self, action: #selector(refreshButtonDidTap), for: .touchUpInside)
        view.tintColor = .black
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 10
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(textField)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var valueChanged: ((String) -> Void)?
    private var buttonDidTap: (() -> Void)?
    
    func config(with title: String,
                value: String,
                isButtonShowed: Bool = false,
                valueChanged: @escaping (String) -> Void,
                buttonDidTap: (() -> Void)? = nil) {
        titleLabel.text = title
        textField.text = value
        self.valueChanged = valueChanged
        self.buttonDidTap = buttonDidTap
        setupUI(isButtonShowed: isButtonShowed)
    }
    
    @objc
    private func textChanged() {
        valueChanged?(textField.text ?? "")
    }
    
    func setupUI(isButtonShowed: Bool) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(stackView)
        if isButtonShowed {
            contentView.addSubview(refreshButton)
        }
        backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        if isButtonShowed {
            NSLayoutConstraint.activate([
                refreshButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                        constant: -.sideMargin),
                refreshButton.widthAnchor.constraint(equalToConstant: 25),
                refreshButton.heightAnchor.constraint(equalToConstant: 25),
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: .topMargin),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: .sideMargin),
                stackView.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor,
                                                    constant: -4),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -.topMargin),
                refreshButton.lastBaselineAnchor.constraint(equalTo: stackView.lastBaselineAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: .topMargin),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: .sideMargin),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -.sideMargin),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -.topMargin)
            ])
        }
    }
    
    @objc
    private func refreshButtonDidTap() {
        buttonDidTap?()
    }
}
