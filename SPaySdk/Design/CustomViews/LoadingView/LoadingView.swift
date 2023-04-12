//
//  LoadingView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.11.2022.
//

import UIKit

private extension CGFloat {
    static let loaderWidth = 80.0
    static let stickTopMargin = 8.0
    static let stickWidth = 38.0
    static let stickHeight = 4.0
}

private extension TimeInterval {
    static let delay: TimeInterval = 0.1
    static let animationDuration = 0.25
}

final class LoadingView: UIView {
    private lazy var loadingImageView: UIImageView = {
        let view = UIImageView()
        view.image = .Common.loader
        return view
    }()

    private lazy var loadingTitle: UILabel = {
        let view = UILabel()
        view.font = .bodi3
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.textAlignment = .center
        return view
    }()
    
    private lazy var stickImageView: UIImageView = {
       let view = UIImageView()
        view.image = .Common.stick
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var loadingStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .margin
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    private lazy var animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2 * Double.pi
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    init(with text: String?) {
        super.init(frame: .zero)
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
        backgroundColor = .backgroundPrimary
        isUserInteractionEnabled = true
        alpha = 0
        loadingStack.isHidden = true
        NSLayoutConstraint.activate([
            loadingImageView.widthAnchor.constraint(equalToConstant: .loaderWidth),
            loadingImageView.heightAnchor.constraint(equalToConstant: .loaderWidth)
        ])
        addSubview(loadingStack)
        loadingStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            loadingStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin)
        ])
        loadingStack.addArrangedSubview(loadingImageView)
        
        addSubview(stickImageView)
        stickImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stickImageView.widthAnchor.constraint(equalToConstant: .stickWidth),
            stickImageView.heightAnchor.constraint(equalToConstant: .stickHeight),
            stickImageView.topAnchor.constraint(equalTo: topAnchor, constant: .stickTopMargin),
            stickImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func show(animate: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .delay, execute: {
            self.loadingStack.isHidden = false
        })
        if animate {
            UIView.animate(withDuration: 0.25,
                           delay: .delay) { [weak self] in
                guard let self = self else { return }
                self.alpha = 1
            } completion: { _ in
                self.loadingImageView.layer.add(self.animation, forKey: "Spin")
            }
        } else {
            self.alpha = 1
            self.loadingImageView.layer.add(self.animation, forKey: "Spin")
        }
    }
}
