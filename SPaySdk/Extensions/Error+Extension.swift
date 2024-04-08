//
//  Error+Extension.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.03.2024.
//

import Foundation

extension Error {
    
    var sdkError: SDKError {
        
        (self as? SDKError) ?? SDKError(.unowned)
    }
}
