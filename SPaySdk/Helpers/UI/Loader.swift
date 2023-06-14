//
//  Loader.swift
//  SPaySdk
//
//  Created by Арсений on 14.03.2023.
//

import UIKit

private extension TimeInterval {
    static let animationDuration = 0.25
}

struct Loader {
    private var window: UIWindow? {
        return UIApplication.shared.keyWindow ?? UIApplication.shared.windows.last
    }
    
    private let text: String?
    private var isNeedToAnimate = false
    
    private var topVC: ContentVC? {
        var navigationController: ContentNC
        if #available(iOS 13.0, *) {
            guard let nc = UIApplication.shared.topViewController as? ContentNC
            else { return nil }
            navigationController = nc
        } else {
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) as? TransparentWindow,
                  let nc = window.topVC as? ContentNC
            else { return nil }
            navigationController = nc
        }
        return navigationController.topViewController as? ContentVC
    }
    
    init(text: String? = nil) {
        self.text = text
    }
    
    func animated(with target: Bool = true) -> Loader {
        var new = self
        new.isNeedToAnimate = target
        return new
    }
    
    @discardableResult
    func show(on vc: UIViewController) -> Loader {
        guard window != nil else { return self }
        if var oldLaoding = vc.view?.subviews.first(where: { $0 is LoadingView }) as? LoadingView {
            oldLaoding.removeFromSuperview()
        }
        let subview = LoadingView(with: text)
        guard let rootView = vc.view else { return self }
        subview.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            subview.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            subview.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            subview.topAnchor.constraint(equalTo: rootView.topAnchor)
        ])
        
        subview.layoutIfNeeded()
        subview.show(animate: isNeedToAnimate)
        return self
    }
    
    @discardableResult
    func hide(from vc: UIViewController) -> Loader {
        guard let subview = vc.view?.subviews.first(where: { $0 is LoadingView }) as? LoadingView else {
            return self
        }
        
        if isNeedToAnimate {
            UIView.animate(withDuration: .animationDuration,
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
