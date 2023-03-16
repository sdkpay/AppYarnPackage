//
//  Fonts.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 22.11.2022.
//

import UIKit

extension UIFont {
    static let header = UIFont(name: "SB Sans Text Semibold", size: 32) ?? defaultFount(with: 32)
    static let subheadline = UIFont(name: "SB Sans Text Semibold", size: 16) ?? defaultFount(with: 16)
    static let bodi1 = UIFont(name: "SBSansText-Regular", size: 16) ?? defaultFount(with: 16)
    static let bodi2 = UIFont(name: "SBSansText-Regular", size: 13) ?? defaultFount(with: 13)
    static let bodi3 = UIFont(name: "SBSansText-Regular", size: 15) ?? defaultFount(with: 15)
}
