//
//  UIFont+Bundle.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

extension UIFont {
    private static var fontsRegistered = false

    static func registerFontsIfNeeded() {
        guard !fontsRegistered,
                let fontURLs = Bundle(for: SBPay.self).urls(forResourcesWithExtension: "ttf", subdirectory: nil)
        else { return }

        fontURLs.forEach({ CTFontManagerRegisterFontsForURL($0 as CFURL,
                                                            .process, nil) })
        fontsRegistered = true
    }
}
