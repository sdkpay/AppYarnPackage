//
//  LoadingView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.11.2022.
//

import UIKit
@_implementationOnly import SPayLottie

private extension CGFloat {
    static let loaderWidth = 40.0
    static let stickTopMargin = 8.0
    static let stickWidth = 38.0
    static let stickHeight = 4.0
}

private extension CGFloat {
    static let logoWidth = 96.0
    static let logoHeight = 48.0
}

private extension TimeInterval {
    static let delay: TimeInterval = 0.1
    static let animationDuration = 0.25
}

extension Int {
    
    static let loadingTag = 987
}

final class LoadingView: UIView {
    
    private lazy var dotsAnimatedView = DotsAnimatedView()
    
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

    private lazy var loadingTitle: UILabel = {
        let view = UILabel()
        view.font = .header2
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.textAlignment = .center
        return view
    }()
    
    private lazy var loadingStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .margin
        view.axis = .vertical
        view.alignment = .center
        return view
    }()

    init(with text: String?) {
        super.init(frame: .zero)
        tag = .loadingTag
        setupUI()
        if let text = text {
            loadingTitle.text = text
            loadingStack.addArrangedSubview(loadingTitle)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .backgroundSecondary
        isUserInteractionEnabled = true
        alpha = 0

        logoImage
            .add(toSuperview: self)
            .size(.equal, to: .init(width: .logoWidth, height: .logoHeight))
            .centerInSuperview()
    }
    
    func show(animate: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .delay, execute: {
            self.loadingStack.isHidden = false
        })
        UIView.animate(withDuration: 0.5,
                       delay: .delay) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
        } completion: { _ in
            self.logoImage.play()
        }
    }
}
