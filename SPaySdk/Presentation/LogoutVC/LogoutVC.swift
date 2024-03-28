//
//  LogoutVC.swift
//  SPaySdk
//
//  Created by Арсений on 17.08.2023.
//

import UIKit

protocol ILogoutVC {
}

final class LogoutVC: ContentVC, ILogoutVC {

    private let presenter: LogoutPresenting
    private let analytics: AnalyticsManager
    
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(base64: UserDefaults.images?.logoIcon ?? "")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Cost.ImageView.size.width / 2
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .header2
        label.text = presenter.getName()
        label.textColor = .textPrimory
        return label
    }()
    
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.text = presenter.getNumber()
        label.textColor = .textSecondary
        label.font = .medium7
        label.textAlignment = .center
        return label
    }()
    
    private(set) lazy var nextButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .orangeBack)
        let string = Strings.Logout.Button.logout
        view.setTitle(string, for: .normal)
        view.layer.cornerRadius = Cost.Button.cornerRadius
        view.addAction {
            self.presenter.logout()
        }
        return view
    }()
    
    private(set) lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        let string = Strings.Logout.Button.Logout.back
        view.setTitle(string, for: .normal)
        view.layer.cornerRadius = Cost.Button.cornerRadius
        view.addAction {
            self.presenter.back()
        }
        return view
    }()
    
    private(set) lazy var buttonStack: UIStackView = {
       let view = UIStackView()
        view.addArrangedSubview(backButton)
        view.addArrangedSubview(nextButton)
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = Cost.Button.spacing
        return view
    }()
    
    init(_ presenter: LogoutPresenting, with userInfo: UserInfo, analytics: AnalyticsManager) {
        self.presenter = presenter
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
        analyticsName = .ProfileView
        self.avatarImage.image = userInfo.sdkGender.icon
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
        analytics.sendAppeared(view: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
        analytics.sendDisappeared(view: self)
    }
    
    private func setupView() {
        avatarImage
            .add(toSuperview: view)
            .size(.equal, to: Cost.ImageView.size)
            .touchEdge(.top, toEdge: .top, ofView: view, withInset: Cost.ImageView.top)
            .centerInSuperview(.horizontal)
            
        nameLabel
            .add(toSuperview: view)
            .centerInSuperview(.horizontal)
            .centerInSuperview(.vertical)
            .touchEdge(.top, toEdge: .bottom, ofView: avatarImage, withInset: Cost.Label.Name.top)
        
        phoneLabel
            .add(toSuperview: view)
            .centerInSuperview(.horizontal)
            .touchEdge(.top, toEdge: .bottom, ofView: nameLabel, withInset: Cost.Label.Phone.top)
        
        buttonStack
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.sideOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.sideOffSet)
            .touchEdge(.bottom, toEdge: .bottom, ofGuide: .safeAreaLayout(of: view))
        
        backButton
           .height(.defaultButtonHeight)
        
        nextButton
            .height(.defaultButtonHeight)
    }
}

extension LogoutVC {
    enum Cost {
        static let sideOffSet: CGFloat = 16.0
        static let height = 56.0
        
        enum Button {
            static let height = Cost.height
            static let cornerRadius: CGFloat = 12.0
            static let spacing = 4.0

            enum Next {
                static let bottom: CGFloat = 10.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = 22
            }
            
            enum Back {
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = Cost.sideOffSet
            }
        }
        
        enum ImageView {
            static let size: CGSize = .init(width: 144, height: 144)
            static let top: CGFloat = 130
            static let cornerRadius: CGFloat = 36.0
        }
        
        enum Label {
            enum Name {
                static let top: CGFloat = 24.0
            }
            
            enum Phone {
                static let top: CGFloat = 8
            }
        }
    }
}
