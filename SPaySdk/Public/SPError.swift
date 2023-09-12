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
        errorDescription = Strings.Error.system
        switch errorState {
        case .noInternetConnection, .badDataFromSBOL, .unauthorizedClient, .personalInfo, .noCards:
            errorDescription = Strings.Error.system
        case .noData, .failDecode, .errorFromServer:
            errorDescription = Strings.Error.format
        case .badResponseWithStatus(let code):
            if code == .errorFormat {
                errorDescription = Strings.Error.format
            } else if code == .errorSystem {
                errorDescription = Strings.Error.system
            }
        case .cancelled:
            errorDescription = Strings.Error.close
        case .timeOut:
            errorDescription = Strings.Error.timeout
        case .ssl:
            errorDescription = Strings.Error.system
        case .errorWithErrorCode(let code):
            switch code {
            case "1":
                errorDescription = Strings.Error.validation
            case "2":
                errorDescription = Strings.Error.system
            case "9":
                errorDescription = Strings.Error.lifeTimeOut
            case "5":
                errorDescription = Strings.Error.inncorectCode
            case "6":
                errorDescription = Strings.Error.trying
            default:
                errorDescription = Strings.Error.system
            }
        }
    }
}
