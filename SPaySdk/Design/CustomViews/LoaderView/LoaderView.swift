//
//  LoaderView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.05.2023.
//

import UIKit

protocol Loadable where Self: UIView {
    func startLoading(with text: String?)
    func stopLoading()
}

extension Loadable {
    func startLoading(with text: String? = nil) {
        let loadView = LoaderView(with: text)
        loadView
            .add(toSuperview: self)
            .centerInSuperview()
        loadView.start()
    }
    
    func stopLoading() {
        let loadingView = subviews.first(where: { $0 is LoaderView })
        loadingView?.removeFromSuperview()
    }
}

final class LoaderView: UIView {
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
    
    init(with text: String? = nil) {
        super.init(frame: .zero)
        loadingTitle.text = text
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        loadingImageView.layer.add(self.animation, forKey: "Spin")
    }
    
    func stop() {
        loadingImageView.layer.removeAllAnimations()
    }
    
    private func setupUI() {
        loadingStack
            .add(toSuperview: self)
            .centerInSuperview()
            .touchEdge(.top, toEdge: .top, ofView: self)
            .touchEdge(.left, toEdge: .left, ofView: self)
            .touchEdge(.right, toEdge: .right, ofView: self)
            .touchEdge(.bottom, toEdge: .bottom, ofView: self)
    }
}
