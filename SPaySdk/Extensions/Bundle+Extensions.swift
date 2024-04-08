//
//  Bundle+Extensions.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 11.01.2023.
//

import Foundation

extension Bundle {
    
    var displayName: String {
        
        if let displayName = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, !displayName.isEmpty {
            return displayName
        } else if let bundleName = object(forInfoDictionaryKey: "CFBundleName") as? String, !bundleName.isEmpty {
            return bundleName
        } else {
            return "No info"
        }
    }
    
    static var sdkBundle: Bundle = {
        return Bundle(for: SPay.self)
    }()

    static var sdkVersion: String {
        sdkBundle.infoDictionary?["SDKVersion"] as? String ?? "No info"
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
