//
//  PaymentModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import UIKit

private extension CGFloat {
    
    static let topMargin: CGFloat = 20.0
}

protocol IPaymentModuleVC { 
    
    func setPayButtonTitle(_ title: String)
}

final class PaymentModuleVC: ModuleVC, IPaymentModuleVC {
    
    private var presenter: PaymentModulePresenting
    
    private lazy var payButton: PaymentButton = {
        let view = PaymentButton()
        view.tapAction = {
            self.presenter.payButtonTapped()
        }
        return view
    }()
    
    init(_ presenter: PaymentModulePresenting) {
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
        payButton.setPayTitle(title)
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
