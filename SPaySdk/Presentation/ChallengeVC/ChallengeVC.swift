//
//  ChallengeVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import UIKit

private extension CGFloat {
    static let imageViewWidth: CGFloat = 24.0
    static let bottom: CGFloat = 44.0
    static let buttonMargin: CGFloat = 4.0
    static let sideMargin: CGFloat = 16.0
    static let heightMultiple = 0.65
}

protocol IChallengeVC {
    func configView(header: String?, subtitle: String?, info: String?, mainButton: String?, cancelButton: String?)
}

final class InfoAlertView: UIView {
    
    var tappedAction: Action?
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .medium4
        view.numberOfLines = 3
        view.textColor = .main
        view.textAlignment = .center
        return view
    }()
    
    private lazy var alertImage: UIImageView = {
        let view = UIImageView()
        view.size(.init(width: .imageViewWidth, height: .imageViewWidth))
        view.image = Asset.warning.image.withRenderingMode(.alwaysOriginal).withTintColor(.main)
        return view
    }()
    
    private lazy var alertStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        view.addArrangedSubview(alertImage)
        view.addArrangedSubview(titleLabel)
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGr)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func tapped() {
        tappedAction?()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func setupUI() {
        alertStack.add(toSuperview: self)
            .touchEdge(.bottom, toSuperviewEdge: .bottom)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
            .centerInSuperview(axis: .y)
    }
}

final class ChallengeVC: ContentVC, IChallengeVC {

    private let presenter: ChallengePresenting
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .header2
        view.numberOfLines = 3
        view.textColor = .mainBlack
        view.textAlignment = .center
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
       let view = UILabel()
        view.font = .medium5
        view.numberOfLines = 0
        view.textColor = .textSecondary
        view.textAlignment = .center
        return view
    }()
    
    private lazy var infoAlertView: InfoAlertView = {
        let view = InfoAlertView()
        view.tappedAction = {
            self.presenter.infoAlertTapped()
        }
        return view
    }()
    
    private lazy var nextButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.addAction {
            self.presenter.confirmTapped()
        }
        return view
    }()
    
    private lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .info)
        view.addAction {
            self.presenter.cancelTapped()
        }
        return view
    }()
    
    private lazy var infoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .center
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(subtitleLabel)
        return view
    }()

    init(_ presenter: ChallengePresenting) {
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
    
    func configView(header: String?, 
                    subtitle: String?,
                    info: String?,
                    mainButton: String?,
                    cancelButton: String?) {
        titleLabel.text = header
        subtitleLabel.text = subtitle
        
        if let info {
            infoAlertView.setTitle(info)
            infoStack.addArrangedSubview(infoAlertView)
        }
        
        nextButton.setTitle(mainButton, for: .normal)
        backButton.setTitle(cancelButton, for: .normal)
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    private func setupUI() {
        
        view
            .height(.equal,
                    to: UIScreen.main.bounds.height * .heightMultiple, priority: .defaultHigh)
        
        let backView = UIView()
        
        backButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .bottom)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
        
        nextButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.bottom, toEdge: .top, ofView: backButton, withInset: .buttonMargin)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
        
        backView
            .add(toSuperview: view)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideMargin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideMargin)
            .touchEdge(.bottom, toEdge: .top, ofView: nextButton, withInset: .buttonMargin)
        
        infoStack
            .add(toSuperview: backView)
            .centerInSuperview()
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
    }
}
