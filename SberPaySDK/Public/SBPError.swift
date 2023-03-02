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
    @objc public var errorDescription: String

    init(errorState: SDKError) {
        errorDescription = .Error.errorSystem
        switch errorState {
        case .noInternetConnection, .badDataFromSBOL, .unauthorizedClient, .personalInfo, .noCards:
            errorDescription = .Error.errorSystem
        case .noData, .failDecode, .errorFromServer:
            errorDescription = .Error.errorFormat
        case .badResponseWithStatus(let code):
            if code == 400 {
                errorDescription = .Error.errorSystem
            } else if code == 500 {
                errorDescription = .Error.errorFormat
            }
        case .cancelled:
            errorDescription = .Error.errorClose
        case .waiting:
            errorDescription = .Error.errorTimeout
        case .timeOut:
            errorDescription = .Error.errorTimeout
        }
    }
}
