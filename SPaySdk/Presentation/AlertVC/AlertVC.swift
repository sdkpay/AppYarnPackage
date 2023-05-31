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
}

protocol IAlertVC {
    func configView(with model: AlertViewModel)
}

final class AlertVC: ContentVC, IAlertVC {
   private lazy var imageView = UIImageView()

    private lazy var alertTitle: UILabel = {
        let view = UILabel()
        view.font = .bodi3
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.textAlignment = .center
        return view
    }()
    
    private lazy var infoStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .margin
        view.axis = .vertical
        view.alignment = .center
        view.addArrangedSubview(imageView)
        view.addArrangedSubview(alertTitle)
        return view
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .buttonSpacing
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .margin
        view.axis = .vertical
        view.alignment = .center
        view.addArrangedSubview(infoStack)
        view.addArrangedSubview(buttonsStack)
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
        
        for item in model.buttons {
            let button = DefaultButton(buttonAppearance: item.type)
            button.setTitle(item.title, for: .normal)
            button.addAction { [weak self] in
                self?.presenter.buttonTapped(item: item)
            }
            button.height(.defaultButtonHeight)
            button.width(.defaultButtonWidth)
            buttonsStack.addArrangedSubview(button)
        }
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        topBarIsHidden = true
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
    
    func setupUI() {
        view.height(.minScreenSize, priority: .defaultLow)

        imageView
            .height(.imageWidth)
            .width(.imageWidth)
        
        contentStack
            .add(toSuperview: view)
            .centerInSuperview(.y)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
    }
}
