//
//  PaymentPartPayModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import UIKit

private extension CGFloat {
    
    static let topMargin: CGFloat = 20.0
}

protocol IPaymentPartPayModuleVC {
    
    func setPayButtonTitle(_ title: String)
    func setButtonEnabled(_ value: Bool)
}

final class PaymentPartPayModuleVC: ModuleVC, IPaymentPartPayModuleVC {

    private var presenter: PaymentPartPayModulePresenting
    
    private lazy var payButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.addAction {
            self.presenter.payButtonTapped()
        }
        return view
    }()
    
    init(_ presenter: PaymentPartPayModulePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
    }
    
    func setPayButtonTitle(_ title: String) {
        payButton.setTitle(title, for: .normal)
    }
    
    func setButtonEnabled(_ value: Bool) {
        payButton.isEnabled = value
    }
    
    private func setupUI() {
        
        payButton
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .top, ofView: view, withInset: .topMargin)
            .touchEdge(.left, toEdge: .left, ofView: view, withInset: .margin)
            .touchEdge(.right, toEdge: .right, ofView: view, withInset: .margin)
            .touchEdge(.bottom, toEdge: .bottom, ofView: view)
            .height(.defaultButtonHeight)
    }
}
