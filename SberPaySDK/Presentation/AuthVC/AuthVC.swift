//
//  AuthVC.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

private extension CGFloat {
    static let banksSpacing = 12.0
    static let bottomMargin = 45.0
    static let topMargin = 20.0
}

protocol IAuthVC {
    func configBanksStack(selected: @escaping (BankApp) -> Void)
}

final class AuthVC: ContentVC, IAuthVC {
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        view.numberOfLines = 0
        view.text = String(stringLiteral: .Auth.authTitle)
        return view
    }()
    
    private lazy var banksStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = .banksSpacing
        return view
    }()
    
   private let presenter: AuthPresenting
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    init(_ presenter: AuthPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configBanksStack(selected: @escaping (BankApp) -> Void) {
        if !banksStack.arrangedSubviews.isEmpty {
            banksStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        }
        for bank in BankApp.allCases {
            let bankView = BankView()
            bankView.config(with: bank) {
                selected(bank)
            }
            banksStack.addArrangedSubview(bankView)
        }
    }
    
    private func setupUI() {
        view.addSubview(banksStack)
        view.addSubview(titleLabel)
        
        let height = view.heightAnchor.constraint(equalToConstant: .minScreenSize)
        height.priority = .defaultLow
        height.isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: .topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin)
        ])
        
        banksStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banksStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .banksSpacing),
            banksStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin),
            banksStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            banksStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.bottomMargin)
        ])
    }
}
