//
//  Bundle+Extensions.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 11.01.2023.
//

import Foundation

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    static var sdkBundle: Bundle = {
        return Bundle(for: SBPay.self)
    }()

    static var curentSdkVersion: String {
        return sdkBundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
