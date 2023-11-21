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
    
    @MainActor
    private var window: UIWindow? {
        UIApplication.shared.windows.last
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
    @MainActor
    func show(on vc: ContentVC) -> Loader {
        
        guard window != nil else { return self }
        
        if vc.view?.subviews.first(where: { $0 is LoadingView }) is LoadingView {
            hide(from: vc)
        }
        
        let subview = LoadingView(with: text)
    
        guard let rootView = vc.view else { return self }
        
        hideContext(from: vc, aniamated: true)
        
        subview
            .add(toSuperview: rootView)
            .centerInSuperview()
        subview.show(animate: isNeedToAnimate)
        return self
    }
    
    @discardableResult
    @MainActor
    func hide(from vc: ContentVC) -> Loader {
        
        guard let subview = vc.view?.subviews.first(where: { $0 is LoadingView }) as? LoadingView else {
            return self
        }
        
        showContext(from: vc, aniamated: true)
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
    
    private func hideContext(from view: ContentVC, aniamated: Bool) {
        
        if aniamated {
            
            view.view.subviews.forEach {
                if $0.tag != .backgroundViewTag, $0.tag != .stickViewTag {
                    $0.alpha = 0
                }
            }
        }
    }
    
    private func showContext(from view: ContentVC, aniamated: Bool) {
        
        if aniamated {
            
            view.view.subviews.forEach { $0.alpha = 1 }
        }
    }
}
