//
//  UIFont+Bundle.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

extension UIFont {
    static func defaultFount(with size: CGFloat) -> UIFont { .systemFont(ofSize: size) }
    
    static func registerFontsIfNeeded() {
        guard let fontURLs = Bundle.sdkBundle.urls(forResourcesWithExtension: "ttf",
                                                   subdirectory: nil)
        else { return }
        
        fontURLs.forEach { font in
            let result = CTFontManagerRegisterFontsForURL(font as CFURL,
                                                          .process,
                                                          nil)
            SBLogger.logFontRegistration(url: font, result: result)
        }
    }
}
