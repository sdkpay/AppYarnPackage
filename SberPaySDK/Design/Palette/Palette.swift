//
//  Palette.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 21.11.2022.
//

import UIKit

extension UIColor {
    static let main = UIColor(named: "Green_primary", in: Bundle(for: SBPay.self), compatibleWith: nil)!
    static let mainSecondary = UIColor(named: "Green_secondary", in: Bundle(for: SBPay.self), compatibleWith: nil)!
    static let backgroundPrimary = UIColor(named: "White", in: Bundle(for: SBPay.self), compatibleWith: nil)!
    static let backgroundSecondary = UIColor(named: "Gray_disabled", in: Bundle(for: SBPay.self), compatibleWith: nil)!
    static let textPrimory = UIColor(named: "Black_primory", in: Bundle(for: SBPay.self), compatibleWith: nil)!
    static let textSecondary = UIColor(named: "Gray_primary", in: Bundle(for: SBPay.self), compatibleWith: nil)!
    static let notification = UIColor(named: "Orange", in: Bundle(for: SBPay.self), compatibleWith: nil)!
}
