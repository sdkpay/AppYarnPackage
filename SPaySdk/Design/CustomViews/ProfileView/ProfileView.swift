//
//  ProfileView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 20.01.2023.
//

import UIKit

enum Gender: Int {
    case female = 0
    case male = 1
    case neutral = 2
    
    var icon: UIImage? {
        switch self {
        case .male:
            return .UserIcon.male
        case .female:
            return .UserIcon.female
        case .neutral:
            return .UserIcon.neutral
        }
    }
}

private extension CGFloat {
    static let iconWidth = 36.0
    static let minMargin = 12.0
}

final class ProfileView: UIView {
    private var buttonAction: Action?
    
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        view.textAlignment = .center
        return view
    }()
    
    private lazy var iconButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = .iconWidth / 2
        view.addTarget(self, action: #selector(iconActionDidTap), for: .touchUpInside)
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with userInfo: UserInfo) {
        nameLabel.text = userInfo.fullName
        iconButton.setImage(userInfo.sdkGender.icon, for: .normal)
        setupUI()
    }
    
    func addAction(action: Action?) {
        buttonAction = action
    }
    
    @objc private func iconActionDidTap() {
        buttonAction?()
    }
    
    private func setupUI() {
        addSubview(iconButton)
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconButton.topAnchor.constraint(equalTo: topAnchor),
            iconButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconButton.widthAnchor.constraint(equalToConstant: .iconWidth),
            iconButton.heightAnchor.constraint(equalToConstant: .iconWidth),
            iconButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: iconButton.leadingAnchor, constant: -.minMargin)
        ])
    }
}
