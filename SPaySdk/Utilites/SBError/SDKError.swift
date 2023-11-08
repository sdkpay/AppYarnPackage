//
//  SBError.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 11.11.2022.
//

import Foundation

enum StatusCode: Int64 {
    case unknownState = 403
    case unknownPayState = 423
    case errorFormat = 400
    case errorPath = 404
    case errorSystem = 500
    case unowned
}

struct SDKError: Error, LocalizedError {

    var code: Int
    var httpCode: Int?
    var description: String
    var publicDescription: String

    init(_ code: ErrorCode,
         httpCode: Int? = nil,
         description: String? = nil,
         publicDescription: String? = nil) {
        self.code = code.rawValue
        self.httpCode = httpCode
        self.description = description ?? code.description
        self.publicDescription = publicDescription ?? code.publicDescription
    }
    
    init(code: Int,
         httpCode: Int? = nil,
         description: String,
         publicDescription: String = Strings.Error.system) {
        self.code = code
        self.httpCode = httpCode
        self.description = description
        self.publicDescription = publicDescription
    }
    
    init(with error: Error) {
        self.code = error._code
        self.httpCode = error._code
        self.description = error.localizedDescription
        self.publicDescription = error.localizedDescription
    }
    
    init?(with data: Data, httpCode: Int? = nil) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else { return nil }
        
        guard let errorCode = json["errorCode"] as? String else { return nil }
        guard errorCode != "0" else { return nil }
        
        guard let description = json["description"] as? String else { return nil }
        
        guard let errorCodeInt = Int(errorCode) else { return nil }
        
        self.code = errorCodeInt
        self.httpCode = httpCode
        self.description = description
        self.publicDescription = ErrorCode(rawValue: code)?.publicDescription ?? "None"
    }

    func represents(_ errorCode: ErrorCode) -> Bool {
        code == errorCode.rawValue
    }
}

enum ErrorCode: Int {
    
    case noInternetConnection = -1
    case noData = -2
    case bankAppNotFound = -3
    case failDecode = -4
    case personalInfo = -5
    case noCards = -7
    case ssl = -8
    case bankAppError = -9
    case unknownState = -403
    case unknownPayState = -423
    case errorFormat = -400
    case errorPath = -404
    case errorSystem = -500
    case unowned = -666
    case validation = 1
    case system = 2
    case timeOut = 9
    case incorrectCode = 5
    case tryingError = 6
    
    var description: String {
        ""
    }
    
    var publicDescription: String {
        var errorDescription = ""
        switch self {
        case .noInternetConnection, .personalInfo, .noCards:
            errorDescription = Strings.Error.system
        case .noData, .failDecode:
            errorDescription = Strings.Error.format
        case .timeOut:
            errorDescription = Strings.Error.timeout
        case .ssl:
            errorDescription = Strings.Error.system
        case .bankAppNotFound:
            errorDescription = Strings.Error.system
        case .unknownState:
            errorDescription = Strings.Error.system
        case .unknownPayState:
            errorDescription = Strings.Error.system
        case .errorFormat:
            errorDescription = Strings.Error.system
        case .errorPath:
            errorDescription = Strings.Error.system
        case .errorSystem:
            errorDescription = Strings.Error.system
        case .unowned:
            errorDescription = Strings.Error.system
        case .validation:
            errorDescription = Strings.Error.system
        case .system:
            errorDescription = Strings.Error.system
        case .incorrectCode:
            errorDescription = Strings.Error.system
        case .tryingError:
            errorDescription = Strings.Error.system
        case .bankAppError:
            errorDescription = Strings.Error.system
        }
        return errorDescription
    }
}

enum ErrorConvertDecoder {
    
    static func getError(decodingError: DecodingError) -> SDKError {
        var description = ""
        
        switch decodingError {
        case let .typeMismatch(_, context):
            description = """
                   mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath.first?.stringValue ?? "None")
                """
        case let .valueNotFound(value, context):
            description = """
                   error: Type '\(value)' mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath.first?.stringValue ?? "None")
                """
        case let .keyNotFound(codingKey, _):
            description = """
                   error: Key '\(codingKey.stringValue)' not found
                """
        case .dataCorrupted(let context):
            description = """
                   error: DataCorrupted
                   context: \(context)
                """
        @unknown default:
            description = """
                   error: unknown decode error
                """
        }
        
        return SDKError(.failDecode, description: description)
    }
}
