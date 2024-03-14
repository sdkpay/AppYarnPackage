//
//  SBPButton.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 09.11.2022.
//

import UIKit

private extension CGFloat {
    static var buttonHeight = 56.0
    static var titleMargin = 8.0
    static var logoWidth = 47.75
    static var logoHeight = 17.1
    static var corner = 12.0
    static var shadowRadius = 15.0
    static var shadowOpacity = 0.3
}

@IBDesignable
public final class SBPButton: UIView {
    @objc
    public var tapAction: Action?
    
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

    public init() {
        super.init(frame: .zero)
        setupUI()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    private func setupUI() {
        backgroundColor = .main
        layer.cornerRadius = .corner
        
        layer.shadowColor = UIColor.main.cgColor
        layer.shadowRadius = .shadowRadius
        layer.shadowOpacity = Float(CGFloat.shadowOpacity)
        layer.shadowOffset = CGSize(width: 0, height: .shadowRadius)
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: .buttonHeight),
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
