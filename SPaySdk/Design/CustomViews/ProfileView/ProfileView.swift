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
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi2
        view.textColor = .textSecondary
        view.textAlignment = .center
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = .iconWidth / 2
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    func config(with userInfo: UserInfo) {
        nameLabel.text = userInfo.fullName
        iconView.image = userInfo.sdkGender.icon
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconView.widthAnchor.constraint(equalToConstant: .iconWidth),
            iconView.heightAnchor.constraint(equalToConstant: .iconWidth),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -.minMargin)
        ])
    }
}
