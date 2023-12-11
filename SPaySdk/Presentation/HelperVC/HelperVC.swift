//
//  HelperVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 19.11.2023.
//

import UIKit

private extension CGFloat {
    static let banksSpacing = 12.0
    static let bottomMargin = 45.0
    static let iconHeight = 176.0
    static let iconWidth = 276.0
    static let topMargin = 20.0
}

protocol IHelperVC {
    func setup(title: String,
               subtitle: String,
               iconUrl: String?,
               needButton: Bool)
}

final class HelperVC: ContentVC, IHelperVC {
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.height(.iconHeight)
        view.width(.iconWidth)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .header4
        view.numberOfLines = 0
        view.textAlignment = .center
        view.textColor = .textPrimory
        return view
    }()
    
    private lazy var sutitleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium5
        view.numberOfLines = 0
        view.textAlignment = .center
        view.textColor = .textPrimory
        return view
    }()
    
    private(set) lazy var mainButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(Strings.Cards.New.title, for: .normal)
        view.addAction {
            Task {
                await self.presenter.confirmTapped()
            }
        }
        view.height(.defaultButtonHeight)
        return view
    }()
    
    private(set) lazy var cancelButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
        view.setTitle(Strings.Return.title, for: .normal)
        view.addAction {
            self.presenter.cancelTapped()
        }
        view.height(.defaultButtonHeight)
        return view
    }()
    
    private lazy var textStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(sutitleLabel)
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 10
        view.addArrangedSubview(imageView)
        view.addArrangedSubview(textStackView)
        return view
    }()
    
    private lazy var buttonStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private let presenter: HelperPresenting
    
    init(_ presenter: HelperPresenting) {
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
    
    func setup(title: String,
               subtitle: String,
               iconUrl: String?,
               needButton: Bool) {
        
        titleLabel.text = title
        sutitleLabel.text = subtitle
        imageView.downloadImage(from: iconUrl)
        
        if needButton {
            buttonStack.addArrangedSubview(mainButton)
        }
        
        buttonStack.addArrangedSubview(cancelButton)
    }
    
    private func setupUI() {
        
        view.height(ScreenHeightState.normal.height, priority: .defaultHigh)

        buttonStack
            .add(toSuperview: view)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Helper.Button.Cancel.bottom, usingRelation: .equal)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Helper.Button.Cancel.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Helper.Button.Cancel.right)
        
        let backView = UIView()
        
        backView
            .add(toSuperview: view)
            .touchEdgesToSuperview([.top, .left, .right])
            .touchEdge(.bottom, toEdge: .top, ofView: buttonStack)
        
        contentStackView
            .add(toSuperview: backView)
            .touchEdgesToSuperview([.left, .right], respectingGuide: .safeAreaLayout)
            .centerInSuperview()
    }
}

private extension HelperVC {
    enum Helper {
        
        static let sideOffSet: CGFloat = 32.0
        
        enum Button {
            
            enum Cancel {
                static let bottom: CGFloat = 44.0
                static let right: CGFloat = .margin
                static let left: CGFloat = .margin
            }
        }
    }
}
