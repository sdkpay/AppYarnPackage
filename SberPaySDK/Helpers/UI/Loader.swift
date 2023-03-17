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

        let rootView = getRootView()
        let subview = LoadingView(with: text)
        guard let rootView = rootView else { return self }
        
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
    func hide() -> Loader {
        
       let rootView = getRootView()
        
        guard let subview = rootView?.subviews.first(where: { $0 is LoadingView }) as? LoadingView  else {
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
    
    private func getRootView() -> UIView? {
        var rootView: UIView
        
        if #available(iOS 13.0, *), UIApplication.shared.supportsMultipleScenes {
            guard let view = UIApplication.shared.topViewController?.view else { return nil }
            rootView = view
        } else {
            guard let view = (window as? TransparentWindow)?.topVC?.view else { return nil }
            rootView = view
        }
        
        return rootView
    }
}

extension UIApplication{
    var topViewController: UIViewController? {
        if keyWindow?.rootViewController == nil {
            return keyWindow?.rootViewController
        }
        
        var pointedViewController = keyWindow?.rootViewController
        
        while pointedViewController?.presentedViewController != nil {
            switch pointedViewController?.presentedViewController {
            case let navagationController as UINavigationController:
                pointedViewController = navagationController.viewControllers.last
            case let tabBarController as UITabBarController:
                pointedViewController = tabBarController.selectedViewController
            default:
                pointedViewController = pointedViewController?.presentedViewController
            }
        }
        return pointedViewController
        
    }
}
