//
//  AuthVC.swift
//  SPaySdk
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
    func configBanksStack(banks: [BankApp],
                          selected: @escaping (BankApp) -> Void)
}

final class AuthVC: ContentVC, IAuthVC {    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        view.numberOfLines = 0
        view.text = ConfigGlobal.localization?.authTitle
        view.alpha = 0
        return view
    }()
    
    private lazy var banksStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = .banksSpacing
        view.alpha = 0
        return view
    }()
    
    private let presenter: AuthPresenting
    
    init(_ presenter: AuthPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBarIsHidden = true
        setupUI()
        presenter.viewDidLoad()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
    }
    
    func configBanksStack(banks: [BankApp], selected: @escaping (BankApp) -> Void) {
        topBarIsHidden = false
        banksStack.alpha = 1
        titleLabel.alpha = 1
        if !banksStack.arrangedSubviews.isEmpty {
            banksStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        }
        for bank in banks {
            let bankView = BankView()
            bankView.config(with: bank) {
                selected(bank)
            }
            banksStack.addArrangedSubview(bankView)
        }
    }
    
    private func setupUI() {
        view.height(.minScreenSize, priority: .defaultLow)
        
        banksStack
            .add(toSuperview: view)
            .centerInSuperview()
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
        
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImage, withInset: .topMargin)
            .touchEdge(.left, toEdge: .left, ofView: logoImage)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.bottom, toEdge: .top, ofView: banksStack, withInset: .banksSpacing)
    }
}
