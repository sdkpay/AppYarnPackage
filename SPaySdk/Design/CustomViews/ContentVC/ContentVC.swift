//
//  ContentVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit
@_implementationOnly import Lottie

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

extension Int {
    static let backgroundViewTag = 888
    static let stickViewTag = 555
}

class ContentVC: LoggableVC {
    
    @MainActor
    var contentNavigationController: ContentNC? {
        parent as? ContentNC
    }
    
    @MainActor
    func setUserInteractionsEnabled(_ value: Bool = true) {
        
        view.window?.viewWithTag(.dimmViewTag)?.isUserInteractionEnabled = value
        contentNavigationController?.view.isUserInteractionEnabled = value
    }
    
    private lazy var stickImageView: UIImageView = {
        let view = UIImageView()
        view.image = .Common.stick
        view.tag = .stickViewTag
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var backgroundView: LottieAnimationView = {
        let view = LottieAnimationView(name: "Background", bundle: Bundle.sdkBundle)
        view.contentMode = .scaleToFill
        view.loopMode = .loop
        view.animationSpeed = 5
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForContainer()
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundView.play()
    }
    
    @MainActor
    func showLoading(with text: String? = nil,
                     animate: Bool = true) {
        Loader(text: text)
            .animated(with: animate)
            .show(on: self)
    }
    
    @MainActor
    func hideLoading(animate: Bool = true) {
        Loader()
            .animated(with: animate)
            .hide(from: self)
    }

    func configUI() {
        
        backgroundView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.bottom, toSuperviewEdge: .bottom)
        
        stickImageView
            .add(toSuperview: view)
            .size(.equal, to: .init(width: .stickWidth, height: .stickHeight))
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .stickTopMargin)
            .centerInSuperview(.x)
    }
}
