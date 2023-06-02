//
//  ContentVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

private extension CGFloat {
    static let logoWidth = 72.0
    static let logoHeight = 36.0
    static let topMargin = 20.0
    static let loaderWidth = 80.0
    static let stickTopMargin = 8.0
    static let stickWidth = 38.0
    static let stickHeight = 4.0
}

private extension TimeInterval {
    static let animationDuration = 0.25
}

class ContentVC: LoggableVC {
    var contentNavigationController: ContentNC? {
        parent as? ContentNC
    }
    
    var userInteractionsEnabled = true {
        didSet {
            view.window?.viewWithTag(.dimmViewTag)?.isUserInteractionEnabled = userInteractionsEnabled
            contentNavigationController?.view.isUserInteractionEnabled = userInteractionsEnabled
        }
    }

    lazy var logoImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(base64: UserDefaults.images?.logoIcon ?? "")
        return view
    }()
    
    private lazy var stickImageView: UIImageView = {
       let view = UIImageView()
        view.image = .Common.stick
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    var topBarIsHidden = false {
        didSet {
            logoImage.isHidden = topBarIsHidden
            profileView.isHidden = topBarIsHidden
        }
    }
    
    private lazy var profileView = ProfileView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForContainer()
        configUI()
    }
    
    func configProfileView(with userInfo: UserInfo) {
        profileView.isHidden = false
        profileView.config(with: userInfo)
    }

    func configUI() {
        profileView.isHidden = true

        view.addSubview(logoImage)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImage.widthAnchor.constraint(equalToConstant: .logoWidth),
            logoImage.heightAnchor.constraint(equalToConstant: .logoHeight),
            logoImage.topAnchor.constraint(equalTo: view.topAnchor, constant: .topMargin),
            logoImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .margin)
        ])
        
        view.addSubview(stickImageView)
        stickImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stickImageView.widthAnchor.constraint(equalToConstant: .stickWidth),
            stickImageView.heightAnchor.constraint(equalToConstant: .stickHeight),
            stickImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: .stickTopMargin),
            stickImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(profileView)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.margin),
            profileView.topAnchor.constraint(equalTo: logoImage.topAnchor)
        ])
    }
}

// ContentVC + Loading
extension ContentVC {
    func showLoading(with text: String? = nil,
                     animate: Bool = true) {
        Loader(text: text)
            .animated(with: animate)
            .show(on: self)
    }
    
    func hideLoading(animate: Bool = true) {
        Loader()
            .animated(with: animate)
            .hide(from: self)
    }
}
