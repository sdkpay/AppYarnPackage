//
//  WebViewVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import UIKit
import WebKit

private extension CGFloat {
    static let topMargin = 24.0
    static let shareMargin = 26.0
    static let shareHeight = 24.0
    static let bottomMargin = 37.0
}

protocol IWebViewVC {
    func setTitle(text: String)
    func goTo(to url: URL)
}

final class WebViewVC: ContentVC, IWebViewVC {
    private lazy var titleLabel: UILabel = {
       let view = UILabel()
        view.font = .header
        view.numberOfLines = 1
        view.textColor = .textPrimory
        return view
    }()
    
    private lazy var shareButton: ActionButton = {
       let view = ActionButton()
        view.setImage(.WebView.share, for: .normal)
        view.addAction { [weak self] in
            self?.presenter.shareButtonTapped()
        }
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        return view
    }()
    
    private lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(String(stringLiteral: .PayPart.accept), for: .normal)
        view.addAction { [weak self] in
            self?.presenter.backButtonTapped()
        }
        return view
    }()

    private let presenter: WebViewPresenter
    
    init(_ presenter: WebViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        topBarIsHidden = true
        setupUI()
    }
    
    func goTo(to url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    func setTitle(text: String) {
        titleLabel.text = text
    }
    
    private func setupUI() {
        view.height(.vcMaxHeight)
        
        shareButton
            .add(toSuperview: view)

        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .top, ofView: view, withInset: .topMargin)
            .touchEdge(.left, toEdge: .left, ofView: view, withInset: .margin)
            .touchEdge(.right, toEdge: .left, ofView: shareButton, withInset: .margin)
        
        shareButton
            .touchEdge(.top, toEdge: .top, ofView: view, withInset: .shareMargin)
            .touchEdge(.right, toEdge: .right, ofView: view, withInset: .margin)
            .height(.shareHeight)
            .width(.shareHeight)
            .centerInView(titleLabel, axis: .y, withOffset: .zero)
        
        webView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: .margin)
            .touchEdge(.left, toEdge: .left, ofView: view, withInset: .margin)
            .touchEdge(.right, toEdge: .right, ofView: view, withInset: .margin)
        
        backButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.top, toEdge: .bottom, ofView: webView, withInset: .margin)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.bottom, toEdge: .bottom, ofView: view, withInset: .bottomMargin)
    }
}
