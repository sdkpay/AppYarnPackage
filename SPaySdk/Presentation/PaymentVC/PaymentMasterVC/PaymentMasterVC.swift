//
//  PaymentVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

protocol IPaymentMasterVC {
    func configShopInfo(with shop: String,
                        iconURL: String?,
                        purchaseInfoText: String?)
    func addSnapShot()
    func setHint(with text: String)
    func setHints(with texts: [String])
    func showPartsView(_ value: Bool)
    func reloadData()
}

final class PaymentMasterVC: ContentVC, IPaymentMasterVC {
   
    private lazy var purchaseModuleVC = PurchaseModuleVC(presenter)
    private lazy var paymentModuleVC = PaymentModuleVC(presenter)
    
    private var presenter: PaymentPresenting
    
    init(_ presenter: PaymentPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideLoading(animate: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
        SBLogger.log(.didDissapear(view: self))
    }
    
    func configShopInfo(with shop: String, iconURL: String?, purchaseInfoText: String?) {
        
        purchaseModuleVC.configShopInfo(with: shop, iconURL: iconURL, purchaseInfoText: purchaseInfoText)
    }
    
    func reloadData() {
        
        paymentModuleVC.reloadData()
        purchaseModuleVC.addSnapShot()
    }
    
    func addSnapShot() {
        
        paymentModuleVC.addSnapShot()
    }
    
    func setHint(with text: String) {
        
        paymentModuleVC.setHint(with: text)
    }
    
    func setHints(with texts: [String]) {
        
        paymentModuleVC.setHints(with: texts)
    }
    
    func showPartsView(_ value: Bool) {
        
        purchaseModuleVC.showPartsView(value)
    }
    
    private func setupUI() {
        
        view.height(presenter.screenHeight.height, priority: .defaultLow)
        
        purchaseModuleVC.view
            .add(toSuperview: view)
            .touchEdgesToSuperview([.top, .left, .right])
        
        self.addChild(purchaseModuleVC)
        purchaseModuleVC.didMove(toParent: self)
        
        paymentModuleVC.view
            .add(toSuperview: view)
            .touchEdgesToSuperview([.bottom, .left, .right])
            .touchEdge(.top, toEdge: .bottom, ofView: purchaseModuleVC.view)
        
        self.addChild(paymentModuleVC)
        paymentModuleVC.didMove(toParent: self)
    }
}
