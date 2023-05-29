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
        errorDescription = .Error.errorSystem
        switch errorState {
        case .noInternetConnection, .badDataFromSBOL, .unauthorizedClient, .personalInfo, .noCards, .partPayError:
            errorDescription = .Error.errorSystem
        case .noData, .failDecode, .errorFromServer:
            errorDescription = .Error.errorFormat
        case .badResponseWithStatus(let code):
            if code == .errorFormat {
                errorDescription = .Error.errorFormat
            } else if code == .errorSystem {
                errorDescription = .Error.errorSystem
            }
        case .cancelled:
            errorDescription = .Error.errorClose
        case .timeOut:
            errorDescription = .Error.errorTimeout
        }
    }
}
