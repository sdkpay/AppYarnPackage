//
//  SBError.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 11.11.2022.
//

import Foundation

enum StatusCode: Int {
    case unknownState = 403
    case unknownPayState = 423
    case errorFormat = 400
    case errorPath = 404
    case errorSystem = 500
    case unowned
}

enum OtpError: String {
    case validation = "1"
    case system = "2"
    case timeOut = "9"
    case incorrectCode = "5"
    case tryingError = "6"
}

enum SDKError: Error, Hashable {
    case noInternetConnection
    case noData
    case badResponseWithStatus(code: StatusCode)
    case failDecode(text: String)
    case badDataFromSBOL(httpCode: Int)
    case unauthorizedClient(httpCode: Int)
    case personalInfo
    case errorWithErrorCode(number: String, httpCode: Int)
    case noCards
    case cancelled
    case timeOut(httpCode: Int)
    case ssl(httpCode: Int)
    
    func represents(_ error: SDKError) -> Bool {
        self == error
    }
}

final class ErrorConvertDecoder {
    
    static func getErrorDescription(decodingError: DecodingError) -> String {
        switch decodingError {
        case let .typeMismatch(_, context):
            return """
                   mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath.first?.stringValue ?? "None")
                """
        case let .valueNotFound(value, context):
            return """
                   error: Type '\(value)' mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath.first?.stringValue ?? "None")
                """
        case let .keyNotFound(codingKey, _):
            return """
                   error: Key '\(codingKey.stringValue)' not found
                """
        case .dataCorrupted(let context):
            return  """
                   error: DataCorrupted
                   context: \(context)
                """
        @unknown default:
            return  """
                   error: unknown decode error
                """
        }
    }
}
