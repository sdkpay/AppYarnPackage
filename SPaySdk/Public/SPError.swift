//
//  SPError.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.11.2022.
//

import Foundation

/// Class for validation SDK errors
@objc
public class SPError: NSObject {
    // Описание ошибки
    @objc public var errorDescription: String

    init(errorState: SDKError) {
        errorDescription = errorState.publicDescription
    }
}
