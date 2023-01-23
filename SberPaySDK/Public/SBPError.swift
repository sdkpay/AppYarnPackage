//
//  SBPError.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 28.11.2022.
//

import Foundation

/// Class for validation SDK errors
@objc
public class SBPError: NSObject {
    // Описание ошибки
    @objc public let errorDescription: String

    init(errorState: SDKError) {
        errorDescription = errorState.description
    }
}
