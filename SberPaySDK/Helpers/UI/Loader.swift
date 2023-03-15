//
//  Loader.swift
//  SberPaySDK
//
//  Created by Арсений on 14.03.2023.
//

import UIKit

fileprivate extension CGFloat {
    static let animationDuration = 0.25
}

struct Loader {
    private var window: UIWindow? {
        return UIApplication.shared.keyWindow ?? UIApplication.shared.windows.last
    }
    
    private let text: String?
    private var isNeedToAnimate = false
    
    init(text: String? = nil) {
        self.text = text
    }
    
    func animated(with target: Bool = true) -> Loader {
        var new = self
        new.isNeedToAnimate = target
        return new
    }
    
    @discardableResult
    func show() -> Loader {
        guard let window = self.window else {
            return self
        }
        
        let subview = LoadingView(with: text)
        subview.translatesAutoresizingMaskIntoConstraints = false
        guard let view = (window as? TransparentWindow)?.topVC?.view else { return self }
        view.addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
    
        subview.layoutIfNeeded()
        subview.show(animate: isNeedToAnimate)
        return self
    }
    
    @discardableResult
    func hide() -> Loader {
        guard let view = (window as? TransparentWindow)?.topVC?.view else { return self }
        guard let subview = view.subviews.first(where: { $0 is LoadingView }) as? LoadingView  else {
            return self
        }
        
        if isNeedToAnimate {
            UIView.animate(withDuration: CGFloat.animationDuration,
                           delay: 0) {
                subview.alpha = 0
            } completion: { _ in
                subview.removeFromSuperview()
            }
        } else {
            subview.removeFromSuperview()
        }
        
        return self
    }
}

