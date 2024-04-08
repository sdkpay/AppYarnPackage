//
//  NetworkDecoding.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

protocol ResponseDecoder {
    func decodeResponse<T: Codable>(data: Data?,
                                    response: URLResponse?,
                                    type: T.Type) throws -> T
    func decodeResponse(data: Data?,
                        response: URLResponse?) throws
    func decodeResponseFull<T: Codable>(data: Data?,
                                        response: URLResponse?,
                                        type: T.Type) throws -> (result: T,
                                                                 headers: HTTPHeaders,
                                                                 cookies: [HTTPCookie])
    func decodeParametersFrom(url: URL) -> Result<BankModel, SDKError>
    func systemError(_ error: Error) -> Error
    func decode<T: Codable>(data: Data, to type: T.Type) throws -> T 
}

extension ResponseDecoder {
    
    func decodeResponse<T: Codable>(data: Data?,
                                    response: URLResponse?,
                                    type: T.Type) throws -> T {
        
        guard let response = response as? HTTPURLResponse else {
            throw SDKError(.noData)
        }
        
        guard let data = data else { throw SDKError(.noData) }
        
        if let error = SDKError(with: data,
                                httpCode: response.statusCode) {
            throw error
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            SBLogger.responseDecodedWithSuccess(for: type)
            return decodedData
        } catch let error as DecodingError {
            SBLogger.responseDecodedWithError(for: type, decodingError: error)
            let error = ErrorConvertDecoder.getError(decodingError: error)
            throw error
        } catch {
            let error = SDKError(.failDecode, httpCode: response.statusCode, description: error.localizedDescription)
            throw error
        }
    }
    
    func decode<T: Codable>(data: Data, to type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            SBLogger.responseDecodedWithSuccess(for: type)
            return decodedData
        } catch let error as DecodingError {
            SBLogger.responseDecodedWithError(for: type, decodingError: error)
            let error = ErrorConvertDecoder.getError(decodingError: error)
            throw error
        } catch {
            let error = SDKError(.failDecode)
            throw error
        }
    }
    
    func decodeResponse(data: Data?,
                        response: URLResponse?) throws {
        
        guard let response = response as? HTTPURLResponse else {
            throw SDKError(.noData)
        }
        
        guard let data = data else { throw SDKError(.noData) }
        
        if let error = SDKError(with: data,
                                httpCode: response.statusCode) {
            throw error
        }
    }
    
    func decodeResponseFull<T: Codable>(data: Data?,
                                        response: URLResponse?,
                                        type: T.Type) throws -> (result: T,
                                                                 headers: HTTPHeaders,
                                                                 cookies: [HTTPCookie]) {
        
        guard let response = response as? HTTPURLResponse else {
            throw SDKError(.noData)
        }
        
        guard let data = data else { throw SDKError(.noData) }
        
        if let error = SDKError(with: data,
                                httpCode: response.statusCode) {
            throw error
        }

        let headers = response.allHeaderFields as? HTTPHeaders ?? [:]
        
        var cookies = [HTTPCookie]()
        
        if let url = response.url {
            cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            SBLogger.responseDecodedWithSuccess(for: type)
            return (decodedData, headers, cookies)
        } catch let error as DecodingError {
            SBLogger.responseDecodedWithError(for: type, decodingError: error)
            let error = ErrorConvertDecoder.getError(decodingError: error)
            throw error
        } catch {
            let error = SDKError(.failDecode, httpCode: response.statusCode, description: error.localizedDescription)
            throw error
        }
    }
    
    func decodeParametersFrom(url: URL) -> Result<BankModel, SDKError> {
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            SBLogger.log("🏦 Cant parse url from bank app \(url.absoluteString)")
            return .failure(SDKError(.bankAppError))
        }
        guard let queryItems = urlComponents.queryItems else {
            SBLogger.log("🏦 Cant parse url from bank app \(url.absoluteString)")
            return .failure(SDKError(.bankAppError))
        }
        
        var parameters = [String: String]()
        queryItems.forEach {
            if let value = $0.value {
                parameters[$0.name] = value
            }
        }
        if let error = parameters["error"] {
            SBLogger.logResponseFromSbolFailed(url, error: error)
            return .failure(SDKError(.bankAppError))
        }
        if let status = parameters["status"], status != "success" {
            SBLogger.logResponseFromSbolFailed(url, error: "status \(status)")
            return .failure(SDKError(.bankAppError))
        }
        SBLogger.logResponseFromSbolCompleted(parameters)
        
        return .success(BankModel(dictionary: parameters))
    }
    
    func systemError(_ error: Error) -> Error {
        
        var sslErrors: [URLError.Code] {
            return [
                .secureConnectionFailed,
                .serverCertificateHasBadDate,
                .serverCertificateUntrusted,
                .serverCertificateHasUnknownRoot,
                .serverCertificateNotYetValid,
                .clientCertificateRejected,
                .clientCertificateRequired
            ]
        }
        
        var timeOutErrors: [URLError.Code] {
            return [
                .timedOut
            ]
        }
        
        var internetError: [URLError.Code] {
            return [
                .networkConnectionLost,
                .notConnectedToInternet,
                .cannotLoadFromNetwork,
                .cancelled
            ]
        }
        
        if sslErrors.contains(where: { $0.rawValue == error._code }) {
            return SDKError(.ssl, httpCode: error._code)
        } else if timeOutErrors.contains(where: { $0.rawValue == error._code }) {
            return SDKError(.timeOut, httpCode: error._code)
        } else if internetError.contains(where: { $0.rawValue == error._code }) {
            return SDKError(.noInternetConnection, httpCode: error._code)
        } else {
            return error
        }
    }
}

// MARK: - KeyCodingStrategy

struct AnyCodingKey: CodingKey {
    
    var stringValue: String
    var intValue: Int?
    
    init(_ base: CodingKey) {
        self.init(stringValue: base.stringValue, intValue: base.intValue)
    }
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
}
