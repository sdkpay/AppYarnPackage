//
//  CheckView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

typealias BoolAction = ((Bool) -> Void)

private extension CGFloat {
    static let checkWidth = 20.0
    static let checkMargin = 22.0
    static let cardWidth = 36.0
    static let topMargin = 12.0
    static let buttonExpend = 25.0
}

final class CheckView: UIView {
    private var checkSelected = true {
        didSet {
            if checkSelected {
                checkButton.setImage(.Common.checkAgreementSelected, for: .normal)
            } else {
                checkButton.setImage(.Common.checkAgreement, for: .normal)
            }
        }
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium3
        view.numberOfLines = 0
        view.textColor = .textSecondary
        return view
    }()
    
    private lazy var checkButton: ExpendedButton = {
        let view = ExpendedButton(.buttonExpend, .buttonExpend)
        view.setImage(.Common.checkAgreementSelected, for: .normal)
        view.addAction { [weak self] in
            guard let self = self else { return }
            self.checkSelected.toggle()
            self.checkTapped?(self.checkSelected)
        }
        return view
    }()
    
    private var checkTapped: BoolAction?
    
    private var textTapped: Action?
    
    init() {
        super.init(frame: .zero)
        setupUI()
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGr)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with text: String? = nil,
                checkSelected: Bool,
                checkTapped: @escaping BoolAction,
                textTapped: Action? = nil) {
        self.checkSelected = checkSelected
        self.checkTapped = checkTapped
        self.textTapped = textTapped
        titleLabel.text = text
        setupUI()
    }
    
    func config(with attributedText: NSAttributedString? = nil,
                checkSelected: Bool,
                checkTapped: @escaping BoolAction,
                textTapped: Action? = nil) {
        self.checkSelected = checkSelected
        self.checkTapped = checkTapped
        self.textTapped = textTapped
        titleLabel.attributedText = attributedText
        setupUI()
    }
    
    @objc
    private func tapped() {
        textTapped?()
    }
    
    private func setupUI() {
        setupForBase()

        addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            checkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: .checkWidth),
            checkButton.heightAnchor.constraint(equalToConstant: .checkWidth)
        ])
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: .checkMargin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: .topMargin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.topMargin)
        ])
    }
}
