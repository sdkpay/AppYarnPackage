//
//  Gallery.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 21.11.2022.
//

import UIKit

extension UIImage {
    enum Common {
        static let logoClear = UIImage("Logo_clear")
        static let logoMain = UIImage("Logo_main")
        static let loader = UIImage("Loader")
        static let failure = UIImage("Failure")
        static let success = UIImage("Success")
        static let checkSelected = UIImage("Check_selected")
        static let checkDeselected = UIImage("Check_deselected")
        static let stick = UIImage("Stick")
    }
    enum Auth {
        static let sberIcon = UIImage("Sber_icon")
        static let sbolIcon = UIImage("Sbol_icon")
    }
    enum Payment {
        static let arrow = UIImage("Arrow")
        static let cart = UIImage("Cart")
    }
    enum UserIcon {
        static let neutral = UIImage("Neutral")
        static let male = UIImage("Male")
        static let female = UIImage("Female")
    }
}
