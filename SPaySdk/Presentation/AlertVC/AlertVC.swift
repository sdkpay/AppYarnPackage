//
//  AlertVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.05.2023.
//

import UIKit
@_implementationOnly import SPayLottie

private extension CGFloat {
    static let imageWidth = 80.0
    static let topMargin = 52.0
    static let buttonsMargin = 32.0
    static let buttonSpacing = 2.0
    static let bottomMargin = 66.0
    static let sideMargin = 16.0
}

protocol IAlertVC {
    func configView(with model: AlertViewModel)
    func playAnimation()
}

final class AlertVC: ContentVC, IAlertVC {
    
    private lazy var imageView: SPayLottieAnimationView = {
        let view = SPayLottieAnimationView()
        return view
    }()

    private lazy var alertTitle: UILabel = {
        let view = UILabel()
        view.font = .header4
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.textAlignment = .center
        return view
    }()
    
    private lazy var alertSubtitle: UILabel = {
       let view = UILabel()
        view.font = .medium2
        view.numberOfLines = 0
        view.textColor = .textSecondary
        view.textAlignment = .center
        return view
    }()
    
    private lazy var alertCostLabel: UILabel = {
       let view = UILabel()
        view.font = .header3
        view.textColor = .mainBlack
        view.textAlignment = .center
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var alertLocalSessionIdLabel: UILabel = {
       let view = UILabel()
        view.font = .medium3
        view.numberOfLines = 0
        view.textColor = .textSecondary
        view.textAlignment = .center
        view.text = presenter.localSessionId
        return view
    }()
    
    private lazy var textStack: UIStackView = {
        let view = UIStackView()
        view.spacing = 8
        view.axis = .vertical
        view.alignment = .center
        view.addArrangedSubview(alertTitle)
        view.addArrangedSubview(alertCostLabel)
        view.addArrangedSubview(alertSubtitle)
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let view = UIStackView()
        view.spacing = 0
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .buttonSpacing
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()
    
    private let presenter: AlertPresenting
    private let analytics: AnalyticsManager
    
    init(_ presenter: AlertPresenting, analytics: AnalyticsManager) {
        self.presenter = presenter
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
        analyticsName = .StatusView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView(with model: AlertViewModel) {
        imageView.animation = SPayLottieAnimation.named(model.lottie, bundle: .sdkBundle)
        alertTitle.text = model.title
        alertSubtitle.text = model.subtite
        
        var imageWidth: CGFloat = 0
        var imageHeight: CGFloat = 0
        
        if model.isFailure {
            contentStack.addArrangedSubview(textStack)
            contentStack.addArrangedSubview(imageView)
            contentStack.addArrangedSubview(alertLocalSessionIdLabel)
            contentStack.addArrangedSubview(alertLocalSessionIdLabel)
            contentNavigationController?.setBackground(Asset.Image.errorBackground.image)
            imageWidth = 250
            imageHeight = 150
        } else {
            contentStack.addArrangedSubview(imageView)
            contentStack.addArrangedSubview(textStack)
            imageWidth = 180
            imageHeight = 140
        }
        
        if let bonuses = model.bonuses {
            let view = BonusesView()
            view.config(with: bonuses)
            textStack.addArrangedSubview(view)
            textStack.setCustomSpacing(25, after: alertSubtitle)
        }
        if !model.isFailure {
            contentStack.addArrangedSubview(alertLocalSessionIdLabel)
            contentStack.setCustomSpacing(25, after: textStack)
        }
        
        imageView
            .height(imageHeight)
            .width(imageWidth)
        
        for item in model.buttons {
            let button = DefaultButton(buttonAppearance: item.type)
            button.setTitle(item.title, for: .normal)
            button.addAction { [weak self] in
                self?.presenter.buttonTapped(item: item)
            }
            button.height(.defaultButtonHeight)
            buttonsStack.addArrangedSubview(button)
        }
        setupUI()
    }
    
    func playAnimation() {
        self.imageView.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.sendAppeared(view: self)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
        analytics.sendDisappeared(view: self)
        contentNavigationController?.setBackground(Asset.Image.background.image)
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func setupUI() {
        
        view.height(ScreenHeightState.normal.height)
        
        buttonsStack
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
            .touchEdge(.bottom, toEdge: .bottom, ofGuide: .safeAreaLayout(of: view), withInset: .margin)
        
        let backView = UIView()
        backView
            .add(toSuperview: view)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
            .touchEdge(.bottom, toEdge: .top, ofView: buttonsStack)
        
        contentStack
            .add(toSuperview: backView)
            .centerInSuperview(.y)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
        
        view.bringSubviewToFront(stickImageView)
    }
}
