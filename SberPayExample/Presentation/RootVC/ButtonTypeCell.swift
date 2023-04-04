//
//  NetworkTypeCell.swift
//  SPaySdkExample
//
//  Created by Арсений on 04.04.2023.
//

import UIKit

private extension CGFloat {
    static let topMargin = 15.0
    static let sideMargin = 20.0
}

final class ButtonTypeCell: UITableViewCell {
    static var reuseID: String { "ButtonTypeCell" }
    private var buttonDidSelect: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.text = "Lang:"
        view.textColor = .black
        return view
    }()
    
    private lazy var selectedModeButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = .darkGray
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        view.addTarget(self, action: #selector(buttonWasSelected), for: .touchUpInside)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 10
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(selectedModeButton)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(stackView)
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
    
    func config(title: String, itemTitle: String, buttonDidSelect: @escaping () -> Void) {
        titleLabel.text = title
        selectedModeButton.setTitle(itemTitle, for: .normal)
        self.buttonDidSelect = buttonDidSelect
    }
    
    @objc
    private func buttonWasSelected() {
        buttonDidSelect?()
    }
}
