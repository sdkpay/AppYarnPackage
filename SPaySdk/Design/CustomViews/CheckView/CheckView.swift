//
//  CheckView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

private extension CGFloat {
    static let checkWidth = 20.0
    static let checkMargin = 22.0
    static let cardWidth = 36.0
}

final class CheckView: UIView, Shakable {
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.numberOfLines = 0
        view.textColor = .textSecondary
        return view
    }()
    
    private lazy var checkButton: ActionButton = {
        let view = ActionButton()
        view.setImage(.Common.checkAgreementSelected, for: .normal)
        view.addAction { [weak self] in
            self?.checkTapped?()
        }
        return view
    }()
    
    private var checkTapped: Action?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with text: String? = nil,
                checkTapped: @escaping Action,
                textTapped: Action? = nil) {
        self.checkTapped = checkTapped
        titleLabel.text = text
        setupUI()
    }
    
    func config(with attributedText: NSAttributedString? = nil,
                checkTapped: @escaping Action,
                textTapped: Action? = nil) {
        titleLabel.attributedText = attributedText
        setupUI()
    }
    
    private func setupUI() {
        addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: .checkWidth),
            checkButton.heightAnchor.constraint(equalToConstant: .checkWidth)
        ])
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: .checkMargin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
