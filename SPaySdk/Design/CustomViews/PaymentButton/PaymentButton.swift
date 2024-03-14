//
//  PaymentButton.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 17.11.2023.
//

import UIKit

private extension CGFloat {
    static var titleMargin = 8.0
    static var logoWidth = 47.75
    static var logoHeight = 17.1
    static var corner = 20.0
    static var shadowRadius = 15.0
    static var shadowOpacity = 0.3
}

final class PaymentButton: UIView {
    
    var tapAction: Action?
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = String(stringLiteral: Strings.Common.Pay.title)
        view.font = .subheadline
        view.textColor = .backgroundPrimary
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(base64: UserDefaults.images?.logoClear ?? "")
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: .logoWidth),
            view.heightAnchor.constraint(equalToConstant: .logoHeight)
        ])
        return view
    }()
    
    private lazy var backgroundButton: ActionButton = {
        let view = ActionButton()
        view.addAction { [weak self] in
            view.isEnabled = false
            self?.tapAction?()
            view.isEnabled = true
        }
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = CGFloat.titleMargin
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(logoImageView)
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
        overrideUserInterfaceStyle = .light
    }
    
    func setPayTitle(_ text: String?) {
        
        titleLabel.text = text
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .main
        layer.cornerRadius = .corner
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        addSubview(backgroundButton)
        backgroundButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundButton.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
