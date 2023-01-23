//
//  UIApplication+TopVC.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 15.12.2022.
//

import UIKit

extension UIApplication {
    static func getTopVC(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let presented = base?.presentedViewController {
            return getTopVC(base: presented)
        }
        return base
    }
}
