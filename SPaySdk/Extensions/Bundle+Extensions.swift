//
//  Bundle+Extensions.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 11.01.2023.
//

import Foundation

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleName") as? String ??
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    
    
    static var sdkBundle: Bundle = {
        return Bundle(for: SPay.self)
    }()

    static var sdkVersion: String {
        sdkBundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "No info"
    }
    
    static var sdkBuild: String {
        sdkBundle.infoDictionary?["CFBundleVersion"] as? String ?? "No info"
    }
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "No info"
    }
    
    static var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "No info"
    }
}
