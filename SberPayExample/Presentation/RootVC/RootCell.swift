//
//  RootCell.swift
//  SberPaySDK
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
        view.addTarget(self, action: #selector(textChanged), for: .allEditingEvents)
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
    
    func config(with title: String,
                value: String,
                keyboardType: UIKeyboardType,
                valueChanged: @escaping (String) -> Void) {
        titleLabel.text = title
        textField.text = value
        self.valueChanged = valueChanged
        setupUI()
    }
    
    @objc
    private func textChanged() {
        valueChanged?(textField.text ?? "")
    }
    
    func setupUI() {
        contentView.addSubview(stackView)
        backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
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
