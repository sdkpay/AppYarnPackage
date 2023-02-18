//
//  Logger.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 30.12.2022.
//

import UIKit

extension String {
    static let start = "🚀 SDK started"
    static let close = "❌ SDK closed"
    static let biZone = "📡 BiZone fingerprint:\n"
}

enum SBLogger: ResponseDecoder {
    private static var logger = Log()

    static func log(_ massage: String) {
        print(massage)
        print("\n\(Date()) \n\(massage)", to: &logger)
    }
    
    static func logRequestStarted(_ request: URLRequest) {
        log(
            """
            ⏱ Request in progress
               path: \(request.url?.absoluteString ?? "None")
               headers: \(headers(request.allHTTPHeaderFields))
               httpMethod: \(request.httpMethod ?? "None")
               body: \(stringToLog(from: request.httpBody))
            """
        )
    }
    
    static func logRequestCompleted(_ target: TargetType,
                                    response: URLResponse?,
                                    data: Data?) {
        let url = ServerURL.appendingPathComponent(target.path)
        var code = "None"
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            code = String(statusCode)
        }
        if code != "200" {
            log(
                """
                ❗️Request failed with code \(code)
                  path: \(url)
                  headers: \(headers(target.headers))
                  httpMethod: \(target.httpMethod)
                  response: \(stringToLog(from: data))
                """
            )
        } else {
            log(
            """
            ✅ Request successed with code \(code)
               path: \(url)
               headers: \(headers(target.headers))
               httpMethod: \(target.httpMethod)
               response: \(stringToLog(from: data))
            """
            )
        }
    }
    
    static func responseDecodedWithSuccess<T>(for type: T.Type) where T: Codable {
        log(
            """
            🟢 Response decoded to type \(type)
            """
        )
    }
    
    static func responseDecodedWithError<T>(for type: T.Type,
                                            decodingError: DecodingError) where T: Codable {
        switch decodingError {
        case let .typeMismatch(t, context):
            log(
                """
                🔴 Response failed to decode to type \(type)
                   error: Type '\(t)' mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath)
                """
            )
        case let .valueNotFound(value, context):
            log(
                """
                🔴 Response failed to decode to type \(type)
                   error: Type '\(value)' mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath)
                """
            )
        case let .keyNotFound(codingKey, context):
            log(
                """
                🔴 Response failed to decode to type \(type)
                   error: Key '\(codingKey)' not found: \(context.debugDescription)
                   codingPath: \(context.codingPath)
                """
            )
        case .dataCorrupted(let context):
            log(
                """
                🔴 Response failed to decode to type \(type)
                   error: DataCorrupted
                   context: \(context)
                """
            )
        @unknown default:
            log(
                """
                🔴 Response failed to decode to type \(type)
                   error: unknown decode error
                """
            )
        }
    }
    
    static func logRequestToSbolStarted(_ url: URL) {
        log(
            """
            ⏱ Request to Sbol in progress
               url: \(url.absoluteString)
            """
        )
    }
    
    static func logResponseFromSbolCompleted(_ parameters: [String: String]) {
        log(
           """
            ✅ Response from Sbol with success
               parameters:
            \(parameters)
            """
       )
    }
    
    static func logResponseFromSbolFailed(_ url: URL, error: String) {
        log(
           """
            ❗️Response from Sbol with error: \(error)
              url: \(url.absoluteString)
            """
       )
    }
    
    static func logRequestPaymentToken(with params: SBPaymentTokenRequest) {
        log(
            """
            ➡️ Merchant called GetPaymentToken
               apiKey: \(params.apiKey)
               clientId: \(params.clientId ?? "none")
               clientName: \(params.clientName)
               amount: \(params.amount)
               currency: \(params.amount)
               mobilePhone: \(params.mobilePhone ?? "none")
               orderNumber: \(params.orderNumber)
               orderDescription: \(params.orderDescription ?? "none")
               language: \(params.language ?? "none")
               recurrentEnabled: \(params.recurrentEnabled)
               recurrentExipiry: \(params.recurrentExipiry ?? "none")
               recurrentFrequency: \(params.recurrentFrequency)
               redirectUri: \(params.redirectUri)
            """
        )
    }
    
    static func logResponsePaymentToken(with params: SBPaymentTokenResponse) {
        log(
            """
            ↩️ Merchant get GetPaymentToken response
               paymentToken: \(params.paymentToken ?? "none")
               paymentTokenId: \(params.paymentTokenId ?? "none")
               tokenExpiration: \(params.tokenExpiration)
               error: \(params.error?.errorDescription ?? "none")
            """
        )
    }
    
    static func stringToLog(from data: Data?) -> NSString {
        if let data = data,
            let decoded = data.prettyPrintedJSONString {
            return decoded
        }
        return "None"
    }
    
    private static func headers(_ headers: [String: String]?) -> String {
        if let headers = headers,
            !headers.isEmpty {
            return headers.json
        } else {
            return "None"
        }
    }
}

struct Log: TextOutputStream {
    func write(_ string: String) {
        let fm = FileManager.default
        let path = fm.urls(for: .documentDirectory,
                           in: .userDomainMask)[0]
            .appendingPathComponent("SBPayLogs")
        try? fm.createDirectory(atPath: path.path, withIntermediateDirectories: true)
        let log = path.appendingPathComponent("log.txt")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
}
