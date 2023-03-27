//
//  UIImage+Bundle.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 21.11.2022.
//

import UIKit

extension UIImage {
    convenience init?(_ named: String) {
        self.init(named: named, in: Bundle(for: SBPay.self), compatibleWith: nil)
    }
}
