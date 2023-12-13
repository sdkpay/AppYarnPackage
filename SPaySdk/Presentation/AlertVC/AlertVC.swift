//
//  AlertVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.05.2023.
//

import UIKit

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
}

final class AlertVC: ContentVC, IAlertVC {
    
    private lazy var backgroundView: UIImageView = {
        // DEBUG
        let view = UIImageView(image: Asset.background.image)
        view.contentMode = .scaleAspectFill
        view.tag = .backgroundViewTag
        return view
    }()
    
    private lazy var imageView: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
        view.spacing = 32
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
    
    init(_ presenter: AlertPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView(with model: AlertViewModel) {
        imageView.image = model.image
        alertTitle.text = model.title
        alertSubtitle.text = model.subtite
        
        var imageWidth: CGFloat = 0
        var imageHeight: CGFloat = 0
        
        if model.isFailure {
            contentStack.addArrangedSubview(textStack)
            contentStack.addArrangedSubview(imageView)
            backgroundView.image = Asset.errorBackground.image
            imageWidth = 200
            imageHeight = 100
        } else {
            contentStack.addArrangedSubview(imageView)
            contentStack.addArrangedSubview(textStack)
            backgroundView.image = Asset.background.image
            imageWidth = 120
            imageHeight = 120
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func setupUI() {
        
        backgroundView.add(toSuperview: view)
            .height(ScreenHeightState.normal.height)
            .touchEdgesToSuperview()
        
        buttonsStack
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .buttonsMargin)
        
        contentStack
            .add(toSuperview: view)
            .centerInSuperview(.y, withOffset: -buttonsStack.bounds.height)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
    }
}
