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
                                    type: T.Type) -> Result<T, SDKError>
    func decodeResponse(data: Data?,
                        response: URLResponse?) -> Result<Void, SDKError>
    func decodeParametersFrom(url: URL) -> Result<BankModel, SDKError>
    func decodeResponseFull<T: Codable>(data: Data?,
                                        response: URLResponse?,
                                        type: T.Type) -> Result<(result: T,
                                                                 headers: HTTPHeaders,
                                                                 cookies: [HTTPCookie]), SDKError>
    func systemError(_ error: Error) -> SDKError
}

extension ResponseDecoder {
    
    func decodeResponse<T: Codable>(data: Data?,
                                    response: URLResponse?,
                                    type: T.Type) -> Result<T, SDKError> {
        
        guard let response = response as? HTTPURLResponse else {
            return .failure(SDKError(.noData))
        }
        
        guard let data = data else { return .failure(.init(.noData)) }
        
        if let error = SDKError(with: data,
                                httpCode: response.statusCode) {
            return .failure(error)
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            SBLogger.responseDecodedWithSuccess(for: type)
            return .success(decodedData)
        } catch let error as DecodingError {
            SBLogger.responseDecodedWithError(for: type, decodingError: error)
            let error = ErrorConvertDecoder.getError(decodingError: error)
            return .failure(error)
        } catch {
            let error = SDKError(.failDecode, httpCode: response.statusCode, description: error.localizedDescription)
            return .failure(error)
        }
    }
    
    func decodeResponse(data: Data?,
                        response: URLResponse?) -> Result<Void, SDKError> {
        
        guard let response = response as? HTTPURLResponse else {
            return .failure(SDKError(.noData))
        }
        
        guard let data = data else { return .failure(.init(.noData)) }
        
        if let error = SDKError(with: data, httpCode: response.statusCode) {
            return .failure(error)
        }
        
        return .success(())
    }
    
    func decodeResponseFull<T: Codable>(data: Data?,
                                        response: URLResponse?,
                                        type: T.Type) -> Result<(result: T,
                                                                 headers: HTTPHeaders,
                                                                 cookies: [HTTPCookie]), SDKError> {
        
        guard let response = response as? HTTPURLResponse else {
            return .failure(SDKError(.noData))
        }
        
        guard let data = data else { return .failure(.init(.noData)) }
        
        if let error = SDKError(with: data, httpCode: response.statusCode) {
            return .failure(error)
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
            return .success((decodedData, headers, cookies))
        } catch let error as DecodingError {
            SBLogger.responseDecodedWithError(for: type, decodingError: error)
            let error = ErrorConvertDecoder.getError(decodingError: error)
            return .failure(error)
        } catch {
            let error = SDKError(.failDecode, httpCode: response.statusCode, description: error.localizedDescription)
            return .failure(error)
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
    
    func systemError(_ error: Error) -> SDKError {
        
        var sslErrors: [URLError.Code] {
            return [
                .secureConnectionFailed,
                .serverCertificateHasBadDate,
                .serverCertificateUntrusted,
                .serverCertificateHasUnknownRoot,
                .serverCertificateNotYetValid,
                .clientCertificateRejected,
                .clientCertificateRequired,
                .cancelled
            ]
        }
        
        var timeOutErrors: [URLError.Code] {
            return [
                .timedOut
            ]
        }
        
        if sslErrors.contains(where: { $0.rawValue == error._code }) {
            return SDKError(.ssl, httpCode: error._code)
        } else if timeOutErrors.contains(where: { $0.rawValue == error._code }) {
            return SDKError(.timeOut, httpCode: error._code)
        } else {
            return SDKError(with: error)
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
