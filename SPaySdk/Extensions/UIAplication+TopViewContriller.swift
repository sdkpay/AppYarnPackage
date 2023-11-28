//
//  UIAplication+TopViewContriller.swift
//  SPaySdk
//
//  Created by Арсений on 17.03.2023.
//

import UIKit

extension UIApplication {
    var topViewController: UIViewController? {
        if self.windows.first(where: { $0.isKeyWindow })?.rootViewController == nil {
            return self.windows.first(where: { $0.isKeyWindow })?.rootViewController
        }
        
        var pointedViewController = self.windows.first(where: { $0.isKeyWindow })?.rootViewController
        
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
