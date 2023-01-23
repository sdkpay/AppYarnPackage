//
//  AlertView.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 25.11.2022.
//

import UIKit

enum AlertState {
    case success
    case failure(text: String? = nil)
}

private extension CGFloat {
    static let imageWidth = 80.0
    static let animationDuration = 0.25
}

final class AlertView: UIView {
    private lazy var imageView = UIImageView()

    private lazy var alertTitle: UILabel = {
        let view = UILabel()
        view.font = .bodi3
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.textAlignment = .center
        return view
    }()
    
    private lazy var alertStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .margin
        view.axis = .vertical
        view.alignment = .center
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        isUserInteractionEnabled = true
        alpha = 0

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: .imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: .imageWidth)
        ])

        addSubview(alertStack)
        alertStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            alertStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            alertStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            alertStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin)
        ])
        alertStack.addArrangedSubview(imageView)
    }
    
    func show() {
        UIView.animate(withDuration: CGFloat.animationDuration,
                       delay: 0) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
        }
    }

    func config(with state: AlertState) {
        backgroundColor = .backgroundPrimary
        switch state {
        case .success:
            imageView.image = .Common.success
        case .failure(let text):
            imageView.image = .Common.failure
            if let text = text {
                alertTitle.text = text
            } else {
                alertTitle.text = String(stringLiteral: .Alert.alertErrorMainTitle)
            }
        }
        if alertTitle.text != nil {
            alertStack.addArrangedSubview(alertTitle)
        }
        UIView.animate(withDuration: CGFloat.animationDuration,
                       delay: 0) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
        }
    }
}
