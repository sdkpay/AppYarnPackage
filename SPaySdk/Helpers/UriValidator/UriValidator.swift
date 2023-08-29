//
//  UriValidator.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.08.2023.
//

import Foundation

enum UriValidator {
    
    static let uriHost = "spay"
    static let redirectSuffix = "://\(uriHost)"
    
    static func validateUri(_ uri: String) -> String {
        if uri.contains(redirectSuffix) {
            return uri
        } else {
#if SDKDEBUG
            return uri
#else
            if uri.contains("://") {
                return uri.components(separatedBy: "//")[0] + redirectSuffix
            } else {
                return uri + redirectSuffix
            }
#endif
        }
    }
}
