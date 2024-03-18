//
//  AuthVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit
import WebKit
@_implementationOnly import SPayLottie

private extension CGFloat {
    static let logoWidth = 96.0
    static let logoHeight = 48.0
}

protocol IAuthVC {
    func goTo(url: URL)
}

final class AuthVC: ContentVC, IAuthVC {
    
    private let presenter: AuthPresenting
    private let analytics: AnalyticsManager
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = self
        return view
    }()
    
    private lazy var logoImage: SPayLottieAnimationView = {
        let imageView: SPayLottieAnimationView
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified, .light:
            imageView = SPayLottieAnimationView(name: Files.Lottie.lightSplashJson.name, bundle: .sdkBundle)
        case .dark:
            imageView = SPayLottieAnimationView(name: Files.Lottie.darkSplashJson.name, bundle: .sdkBundle)
        @unknown default:
            imageView = SPayLottieAnimationView(name: Files.Lottie.lightSplashJson.name, bundle: .sdkBundle)
        }
        imageView.loopMode = .loop
        return imageView
    }()
    
    init(_ presenter: AuthPresenting, analytics: AnalyticsManager) {
        self.presenter = presenter
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
        analyticsName = .AuthView
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
        analytics.sendAppeared(view: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.logoImage.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics.sendDisappeared(view: self)
        SBLogger.log(.didDissapear(view: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func goTo(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        webView.load(request)
    }
    
    private func setupUI() {
        
        view.height(ScreenHeightState.normal.height)
        
        logoImage
            .add(toSuperview: view)
            .size(.equal, to: .init(width: .logoWidth, height: .logoHeight))
            .centerInSuperview()
    }
}

extension AuthVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            CertificateValidator.validate(defaultHandling: false,
                                          challenge: challenge,
                                          completionHandler: completionHandler)
        }
    }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return }
            
            SBLogger.log("🔗 Sid go to: \(url.absoluteString)")
            presenter.webViewGoTo(url: url)
            decisionHandler(.allow)
        }
}
