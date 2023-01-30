//
//  ContentVC.swift
//  SberPaySDK
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

class ContentVC: UIViewController {
    var isLoading = false
    
    var contentNavigationController: ContentNC? {
        parent as? ContentNC
    }

    private var loadingView: LoadingView?
    private var alertView: AlertView?

    lazy var logoImage: UIImageView = {
        let view = UIImageView()
        view.image = .Common.logoMain
        return view
    }()
    
    private lazy var stickImageView: UIImageView = {
       let view = UIImageView()
        view.image = .Common.stick
        view.contentMode = .scaleAspectFill
        return view
    }()
    
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

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        NotificationCenter.default.post(name: Notification.Name(closeSDKNotification), object: nil, userInfo: nil)
        super.dismiss(animated: flag, completion: completion)
    }
}

// ContentVC + Loading
extension ContentVC {
    func showLoading(with text: String? = nil, animate: Bool = true) {
        let loadingView = LoadingView(with: text)
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        view.bringSubviewToFront(loadingView)
        view.bringSubviewToFront(stickImageView)
        view.layoutIfNeeded()
        self.loadingView = loadingView
        self.loadingView?.show(animate: animate)
    }
    
    func hideLoading(animationCompletion: Action? = nil, animate: Bool = true) {
        if animate {
            UIView.animate(withDuration: .animationDuration,
                           delay: 0) {
                self.loadingView?.alpha = 0
            } completion: { _ in
                self.loadingView?.removeFromSuperview()
                self.loadingView = nil
                self.isLoading = false
                animationCompletion?()
            }
        } else {
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
            self.isLoading = false
            animationCompletion?()
        }
    }
}

// ContentVC + Alert
extension ContentVC {
    func showAlert(with alertState: AlertState) {
        let alertView = AlertView()
        alertView.config(with: alertState)
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        view.bringSubviewToFront(stickImageView)
        self.alertView = alertView
        self.alertView?.show()
    }
    
    func hideAlert(animationCompletion: Action? = nil) {
        guard isLoading else { return }
        UIView.animate(withDuration: .animationDuration,
                       delay: 0) {
            self.alertView?.alpha = 0
        } completion: { [weak self] _ in
            self?.alertView?.removeFromSuperview()
            self?.alertView = nil
            self?.isLoading = false
            animationCompletion?()
        }
    }
}
