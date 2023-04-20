//
//  BankView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 07.12.2022.
//

import UIKit

private extension CGFloat {
    static let textMargin = 12.0
    static let logoWidth = 36.0
}

final class BankView: ContentView {
    private lazy var logoImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
       let view = UILabel()
        view.font = .bodi1
        view.textColor = .textPrimory
        return view
    }()

    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with bank: BankApp, action: @escaping Action) {
        titleLabel.text = bank.name
        logoImageView.image = UIImage(base64: bank.icon)
        self.action = action
        setupUI()
    }
    
    private func setupUI() {
        addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            logoImageView.widthAnchor.constraint(equalToConstant: .logoWidth),
            logoImageView.heightAnchor.constraint(equalToConstant: .logoWidth),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: .textMargin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
