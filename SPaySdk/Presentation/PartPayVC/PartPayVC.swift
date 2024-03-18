//
//  PartPayVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

protocol IPartPayVC {

    func setButtonEnabled(value: Bool)
}

final class PartPayVC: ContentVC, IPartPayVC {

    private(set) lazy var acceptButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(Consts.Button.Accept.title, for: .normal)
        view.addAction {
            self.presenter.acceptButtonTapped()
        }
        return view
    }()
    
    private lazy var cancelButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .info)
        view.setTitle(Consts.Button.Cancel.title, for: .normal)
        view.addAction {
            self.presenter.backButtonTapped()
        }
        return view
    }()
    
    private var partPayModule: ModuleVC {
        presenter.partPayModule
    }
    
    private let presenter: PartPayPresenter
    private var analytics: AnalyticsManager
        
    init(_ presenter: PartPayPresenter, analytics: AnalyticsManager) {
        self.analytics = analytics
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        analyticsName = .BNPLView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
        SBLogger.log(.didLoad(view: self))
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

    func setButtonEnabled(value: Bool) {
        acceptButton.isEnabled = value
    }
    
    private func setupUI() {

        self.addChild(partPayModule)
        partPayModule.didMove(toParent: self)
        
        partPayModule.view
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toSuperviewEdge: .top)
        
        cancelButton
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Button.Cancel.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.Button.Cancel.rightOffSet)
            .touchEdge(.bottom, toEdge: .bottom, ofGuide: .safeAreaLayout(of: view))
            .height(Consts.Button.Cancel.height)

        acceptButton
            .add(toSuperview: view)
            .height(Consts.Button.Accept.height)
            .touchEdge(.top, toEdge: .bottom, ofView: partPayModule.view, withInset: Consts.Button.Accept.leftOffSet)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Button.Accept.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.Button.Accept.rightOffSet)
            .touchEdge(.bottom, toEdge: .top, ofView: cancelButton, withInset: Consts.Button.Accept.bottomOffSet)
    }
}

private extension PartPayVC {
    enum Consts {
        static let margin: CGFloat = 16.0

        enum Button {
            enum Accept {
                static let title = String(stringLiteral: Strings.PartPay.Accept.title)
                
                static let topOffSet: CGFloat = 20.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
                static let bottomOffSet: CGFloat = 10.0
                static let height: CGFloat = 56.0
            }
            
            enum Cancel {
                static let title = String(stringLiteral: Strings.PartPay.Cancel.title)
                
                static let topOffSet: CGFloat = 20.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
                static let height: CGFloat = 56.0
            }
        }
    }
}
