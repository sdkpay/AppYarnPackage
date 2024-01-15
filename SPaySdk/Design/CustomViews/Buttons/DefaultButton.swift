//
//  DefaultButton.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

private struct ButtonColorScheme {
    var backgroundColor: UIColor
    var titleColor: UIColor
    var borderColor: UIColor
    var borderWidth: CGFloat

    init(backgroundColor: UIColor = .main,
         titleColor: UIColor = Asset.whiteAlways.color,
         borderColor: UIColor = .main,
         borderWidth: CGFloat = 0) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

enum DefaultButtonAppearance {
    case full
    case clear
    case cancel
    case info
    case blackBack
    case orangeBack
    
    fileprivate var selected: ButtonColorScheme {
        switch self {
        case .full:
            return ButtonColorScheme()
        case .cancel:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .info:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .notification)
        case .clear:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .blackBack:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .orangeBack:
            return ButtonColorScheme(backgroundColor: .backgroundSecondary,
                                     titleColor: .notification)
        }
    }
    
    fileprivate var normal: ButtonColorScheme {
        switch self {
        case .full:
            return ButtonColorScheme()
        case .cancel:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .info:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .clear:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .blackBack:
            return ButtonColorScheme(backgroundColor: .mainBlack,
                                     titleColor: .white)
        case .orangeBack:
            return ButtonColorScheme(backgroundColor: .backgroundSecondary,
                                     titleColor: .notification)
        }
    }
    
    fileprivate var disabled: ButtonColorScheme {
        switch self {
        case .full:
            return ButtonColorScheme(backgroundColor: .backgroundDisabled,
                                     titleColor: .textSecondary,
                                     borderColor: .clear,
                                     borderWidth: .zero)
        case .cancel:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .info:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .notification)
        case .clear:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .main)
        case .blackBack:
            return ButtonColorScheme(backgroundColor: .clear,
                                     titleColor: .textPrimory)
        case .orangeBack:
            return ButtonColorScheme(backgroundColor: .backgroundSecondary,
                                     titleColor: .notification)
        }
    }
}

final class DefaultButton: ActionButton {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                let scheme = scheme.selected
                layer.borderColor = scheme.borderColor.cgColor
                layer.borderWidth = scheme.borderWidth
            } else {
                let scheme = scheme.normal
                layer.borderColor = scheme.borderColor.cgColor
                layer.borderWidth = scheme.borderWidth
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                let scheme = scheme.disabled
                layer.borderColor = scheme.borderColor.cgColor
                layer.borderWidth = scheme.borderWidth
            } else {
                let scheme = scheme.normal
                layer.borderColor = scheme.borderColor.cgColor
                layer.borderWidth = scheme.borderWidth
            }
        }
    }

    private let scheme: DefaultButtonAppearance

    init(buttonAppearance: DefaultButtonAppearance) {
        self.scheme = buttonAppearance
        super.init(frame: .zero)
        applyScheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = .defaultButtonCorner
    }

    private func applyScheme() {
        titleLabel?.font = .medium5
        let selected = scheme.selected
        let normal = scheme.normal
        let disabled = scheme.disabled

        setTitleColor(selected.titleColor, for: .selected)
        setTitleColor(normal.titleColor, for: .normal)
        setTitleColor(disabled.titleColor, for: .disabled)

        setBackgroundColor(selected.backgroundColor, for: .selected)
        setBackgroundColor(normal.backgroundColor, for: .normal)
        setBackgroundColor(disabled.backgroundColor, for: .disabled)

        layer.borderColor = normal.borderColor.cgColor
        layer.borderWidth = normal.borderWidth
    }
}
