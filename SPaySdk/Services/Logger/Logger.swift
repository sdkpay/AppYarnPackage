//
//  Logger.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 30.12.2022.
//

import UIKit

extension String {
    static let version = "🔨 Version: \(Bundle.appVersion) build: \(Bundle.appBuild)"
    static let start = "🚀 SDK started"
    static let close = "❌ SDK closed"
    static let biZone = "📡 BiZone fingerprint:\n"
    static let userReturned = "🔙 User returned by himself"
}

enum SBObjectState {
    case start(obj: Any)
    case stop(obj: Any)
}

enum SBLoggerViewState {
    case didLoad(view: Any)
    case willAppear(view: Any)
    case didAppear(view: Any)
    case didDissapear(view: Any)
}

enum LogLevel {
    case merchant
    case debug(level: DebugLogLevel)
}

enum DebugLogLevel: String, CaseIterable {
    case bank = "Auth"
    case network = "Network"
    case lifeCycle = "LifeCycle"
    case storage = "Storage"
    case defaultLevel = "Default"
}

enum SBLogger: ResponseDecoder {
    private static var logger = Log()
    
    static func log(level: LogLevel = .debug(level: .defaultLevel), _ massage: String) {
        switch level {
        case .merchant:
            NSLog(massage)
        case let .debug(level: level):
            guard RemoteConfig.shared.needLogs else { return }
            print(massage)
            print("|\(level.rawValue) \(Date()) \n\(massage)", to: &logger)
        }
    }
    
    static func logRequestStarted(_ request: URLRequest) {
        log(
            level: .debug(level: .network),
            """
            ⏱ Request in progress
               path: \(request.url?.absoluteString ?? "None")
               headers: \(headers(request.allHTTPHeaderFields))
               httpMethod: \(request.httpMethod ?? "None")
               body: \(stringToLog(from: request.httpBody))
            """)
    }
    
    static func logRequestCompleted(_ target: TargetType,
                                    response: URLResponse?,
                                    data: Data?) {
        let url = ServerURL.appendingPathComponent(target.path)
        var code = "None"
        var headers = "None"
        if let response = response as? HTTPURLResponse {
            code = String(response.statusCode)
            headers = response.allHeaderFields.json
        }
        if code != "200" {
            log(
                level: .debug(level: .network),
                """
                ❗️Request failed with code \(code)
                  path: \(url)
                  headers: \(headers)
                  httpMethod: \(target.httpMethod)
                  response: \(stringToLog(from: data))
                """
            )
        } else {
            log(
                level: .debug(level: .network),
                """
            ✅ Request successed with code \(code)
               path: \(url)
               headers: \(headers)
               httpMethod: \(target.httpMethod)
               response: \(stringToLog(from: data))
            """
            )
        }
    }
    
    static func responseDecodedWithSuccess<T>(for type: T.Type) where T: Codable {
        log(
            level: .debug(level: .network),
            """
            🟢 Response decoded to type \(type)
            """
        )
    }
    
    static func requestCancelled(_ request: URLRequest) {
        log(
            level: .debug(level: .network),
            """
            🚫 Request cancelled
               path: \(request.url?.absoluteString ?? "None")
               headers: \(headers(request.allHTTPHeaderFields))
               httpMethod: \(request.httpMethod ?? "None")
               body: \(stringToLog(from: request.httpBody))
            """
        )
    }
    
    static func responseDecodedWithError<T>(for type: T.Type,
                                            decodingError: DecodingError) where T: Codable {
        switch decodingError {
        case let .typeMismatch(t, context):
            log(
                level: .debug(level: .network),
                """
                🔴 The response could not be decoded for \(type)
                   error: Type '\(t)' mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath.first?.stringValue ?? "None")
                """
            )
        case let .valueNotFound(value, context):
            log(
                level: .debug(level: .network),
                """
                🔴 The response could not be decoded for \(type)
                   error: Type '\(value)' mismatch: \(context.debugDescription)
                   codingPath: \(context.codingPath.first?.stringValue ?? "None")
                """
            )
        case let .keyNotFound(codingKey, _):
            log(
                level: .debug(level: .network),
                """
                🔴 The response could not be decoded for \(type)
                   error: Key '\(codingKey.stringValue)' not found
                """
            )
        case .dataCorrupted(let context):
            log(
                level: .debug(level: .network),
                """
                🔴 The response could not be decoded for \(type)
                   error: DataCorrupted
                   context: \(context)
                """
            )
        @unknown default:
            log(
                level: .debug(level: .network),
                """
                🔴 The response could not be decoded for \(type)
                   error: unknown decode error
                """
            )
        }
    }
    
    static func logRequestToSbolStarted(_ url: URL) {
        var parameters = [String: String]()
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = urlComponents.queryItems
        else {
            parameters = ["None": "None"]
            return
        }
        queryItems.forEach {
            if let value = $0.value {
                parameters[$0.name] = value
            }
        }
        log(
            level: .debug(level: .bank),
            """
            ⏱ Request to Sbol in progress
               parameters:
            \(parameters.json)
               url: \(url.absoluteString)
            """
        )
    }
    
    static func logResponseFromSbolCompleted(_ parameters: [String: String]) {
        log(
            level: .debug(level: .bank),
            """
            ✅ Response from Sbol with success
               response:
            \(parameters.json)
            """
        )
    }
    
    static func logResponseFromSbolFailed(_ url: URL, error: String) {
        log(
            level: .debug(level: .bank),
            """
            ❗️Response from Sbol with error: \(error)
              url: \(url.absoluteString)
            """
        )
    }
    
    static func logRequestPaymentToken(with params: SPaymentTokenRequest) {
        log(
            level: .debug(level: .defaultLevel),
            """
            ➡️ Merchant called GetPaymentToken
               merchantLogin: \(params.merchantLogin ?? "none")
               amount: \(params.amount ?? 0)
               currency: \(params.currency ?? "none")
               mobilePhone: \(params.mobilePhone ?? "none")
               orderNumber: \(params.orderNumber ?? "none")
               orderDescription: \(params.orderDescription ?? "none")
               language: \(params.language ?? "none")
               recurrentExipiry: \(params.recurrentExipiry ?? "none")
               recurrentFrequency: \(params.recurrentFrequency)
               redirectUri: \(params.redirectUri)
            """
        )
    }
    
    static func logResponsePaymentToken(with params: SPaymentTokenResponse) {
        log(
            level: .debug(level: .defaultLevel),
            """
            ↩️ Merchant get GetPaymentToken response
               paymentToken: \(params.paymentToken ?? "none")
               paymentTokenId: \(params.paymentTokenId ?? "none")
               tokenExpiration: \(params.tokenExpiration)
               error: \(params.error?.errorDescription ?? "none")
            """
        )
    }
    
    static func logDownloadImageFromCache(with urlString: String) {
        log(
            level: .debug(level: .network),
            """
            💿 Download image from cache by url \(urlString)
            """
        )
    }
    
    static func logStartDownloadingImage(with urlString: String?) {
        log(
            level: .debug(level: .network),
            """
            🌐 Start downloading image by string:
               \(urlString ?? "")
            """
        )
    }
    
    static func logDownloadImageWithError(with error: ImageDownloaderError,
                                          urlString: String? = nil,
                                          placeholder: UIImage?) {
        switch error {
        case .urlIsNil:
            log(
                level: .debug(level: .network),
                """
                🔴 Not URL Image String,
                   placeholder: \(placeholder?.assetName ?? "")
                """
            )
        case .invalidURL:
            log(
                level: .debug(level: .network),
                """
                🔴 URL in unsupported format
                   \(urlString ?? ""),
                   placeholder: \(placeholder?.assetName ?? "")
                """
            )
        case .dataIsNil:
            log(
                level: .debug(level: .network),
                """
                🔴 Data is nil by url
                   \(urlString ?? ""),
                   placeholder: \(placeholder?.assetName ?? "")
                """
            )
        case .networkError(let error):
            log(
                level: .debug(level: .network),
                """
                🔴 Dowload completed with error:
                   \(error.localizedDescription),
                   placeholder: \(placeholder?.assetName ?? "")
                """
            )
        case .imageNotCreated:
            log(
                level: .debug(level: .network),
                """
                🔴 Image not created by url
                   \(urlString ?? ""),
                   placeholder: \(placeholder?.assetName ?? "")
                """
            )
        }
    }
    
    static func logDownloadImageWithSuccess(with urlString: String) {
        log(
            level: .debug(level: .network),
            """
            🟢 Download image with success by string:
               \(urlString)
            """
        )
    }
    
    static func logLocatorRegister(_ key: String) {
        log(
            level: .debug(level: .lifeCycle),
            """
            ☑️ Locator register service: \(key)
            """
        )
    }
    
    static func logLocatorResolve(_ key: String) {
        log(
            level: .debug(level: .lifeCycle),
            """
            🔘 Locator resolve service: \(key)
            """
        )
    }
    
    static func logSavedData(_ size: Int) {
        log(
            level: .debug(level: .storage),
            """
            ⬇️ Saved data by size = \(size) byte
            """
        )
    }
    
    static func logCurrenConnectionType(_ type: String) {
        log(
            level: .debug(level: .lifeCycle),
            """
            💎 Current connection type = \(type)
            """
        )
    }
    
    static func logStartSdkTime(_ time: Double) {
        let seconds = String(format: "%.4f", time)
        log(
            level: .debug(level: .lifeCycle),
            """
            ⏰ Start SDK time = \(seconds)
            """
        )
    }
    
    static func logScreenDownloadTime(_ time: Double, screen: String) {
        let seconds = String(format: "%.4f", time)
        log(
            level: .debug(level: .lifeCycle),
            """
            ⏱️ Screen \(screen) download time = \(seconds) second
            """
        )
    }
    
    static func logNetworkDownloadingDataSize(_ size: Int) {
        log(
            level: .debug(level: .network),
            """
            💽 Network data size = \(size) bytes
            """
        )
    }
    
    static func log(_ state: SBObjectState) {
        switch state {
        case .start(let obj):
            log(
                level: .debug(level: .lifeCycle),
                """
                ❇️ Service \(String(describing: type(of: obj))) inited
                """
            )
        case .stop(let obj):
            log(
                level: .debug(level: .lifeCycle),
                """
                ❎ Service \(String(describing: type(of: obj))) deinit
                """
            )
        }
    }
    
    static func log(_ state: SBLoggerViewState) {
        switch state {
        case .didLoad(let view):
            log(
                level: .debug(level: .lifeCycle),
                """
                🛠 ViewDidLoad \(String(describing: type(of: view)))
                """
            )
        case .willAppear(let view):
            log(
                level: .debug(level: .lifeCycle),
                """
                📱 ViewWillAppear \(String(describing: type(of: view)))
                """
            )
        case .didAppear(let view):
            log(
                level: .debug(level: .lifeCycle),
                """
                📲 ViewDidAppear \(String(describing: type(of: view)))
                """
            )
        case .didDissapear(view: let view):
            log(
                level: .debug(level: .lifeCycle),
                """
                📵 ViewDidDissapear \(String(describing: type(of: view)))
                """
            )
        }
    }
    
    static func log(obj: Any,
                    name: String = "Custom log",
                    functionName: String = #function,
                    fileName: String = #file,
                    lineNumber: Int = #line) {
        log(
            level: .debug(level: .defaultLevel),
            """
            📄 Log name: \(name)
               class: \(String(describing: type(of: obj)))
               functionName: \(functionName)
               fileName: \(fileName)
               lineNumber: \(lineNumber)
            """
        )
    }
    
    static func logThread(obj: Any,
                          thread: Thread = .current,
                          functionName: String = #function,
                          fileName: String = #file,
                          lineNumber: Int = #line) {
        log(
            level: .debug(level: .defaultLevel),
            """
            🗄 Thread info for functionName: \(functionName)
               thread: \(thread.threadName)
               queue: \(thread.queueName)
               class: \(String(describing: type(of: obj)))
               fileName: \(fileName)
               lineNumber: \(lineNumber)
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
            handle.write(string.data(using: .utf8) ?? Data())
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
}
