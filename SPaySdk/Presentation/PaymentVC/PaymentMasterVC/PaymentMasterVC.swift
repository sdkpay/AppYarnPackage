//
//  PaymentVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

private extension CGFloat {
    
    static let cancelTopMargin: CGFloat = 8.0
}

protocol IPaymentMasterVC {
    func setCancelTitle(_ string: String)
}

final class PaymentMasterVC: ContentVC, IPaymentMasterVC {
    
    private var presenter: PaymentModuleMasterPresenting
    private var analytics: AnalyticsManager
    
    private(set) lazy var cancelButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
        view.addAction {
            self.presenter.cancelTapped()
        }
        view.height(.defaultButtonHeight)
        return view
    }()
    
    init(_ presenter: PaymentModuleMasterPresenting,
         analytics: AnalyticsManager) {
        self.presenter = presenter
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var modulsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupModulsStack()
        setupUI()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideLoading(animate: true)
        contentNavigationController?.setBackground(Asset.Image.background.image)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.sendAppeared(view: self)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics.sendDisappeared(view: self)
        SBLogger.log(.didDissapear(view: self))
    }
    
    func setCancelTitle(_ string: String) {
        
        cancelButton.setTitle(string, for: .normal)
    }
    
    private func setupModulsStack() {
        
        let moduls = presenter.paymentsModuls
        
        for module in moduls {
            
            self.addChild(module)
            module.didMove(toParent: self)
            modulsStackView.addArrangedSubview(module.view)
        }
    }
    
    private func setupUI() {
        
        if let viewHeight = presenter.viewHeight {
            view.height(viewHeight, usingRelation: .greaterThanOrEqual)
        }
        
        modulsStackView
            .add(toSuperview: view)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
        
        cancelButton
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: modulsStackView, withInset: .cancelTopMargin)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.bottom, toEdge: .bottom, ofGuide: .safeAreaLayout(of: view))
    }
}
