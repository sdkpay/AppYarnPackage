//
//  LoadingView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.11.2022.
//

import UIKit

private extension CGFloat {
    static let loaderWidth = 40.0
    static let stickTopMargin = 8.0
    static let stickWidth = 38.0
    static let stickHeight = 4.0
}

private extension TimeInterval {
    static let delay: TimeInterval = 0.1
    static let animationDuration = 0.25
}

final class LoadingView: UIView {
    
    private lazy var dotsAnimatedView = DotsAnimatedView()

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
        
        addSubview(loadingStack)
        loadingStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            loadingStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin)
        ])
          
        loadingStack.addArrangedSubview(dotsAnimatedView)
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
                self.dotsAnimatedView.startAnimation()
            }
        } else {
            self.alpha = 1
            self.dotsAnimatedView.startAnimation()
        }
    }
}
