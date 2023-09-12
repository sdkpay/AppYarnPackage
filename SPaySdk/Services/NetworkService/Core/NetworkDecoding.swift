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
                                    error: Error?,
                                    type: T.Type) -> Result<T, SDKError>
    func decodeResponse(data: Data?,
                        response: URLResponse?,
                        error: Error?) -> Result<Void, SDKError>
    func decodeParametersFrom(url: URL) -> Result<BankModel, SDKError>
}

extension ResponseDecoder {
    
    func decodeResponse<T: Codable>(data: Data?,
                                    response: URLResponse?,
                                    error: Error?,
                                    type: T.Type) -> Result<T, SDKError> {

        if let error = systemError(error) {
            return .failure(error)
        }
    
        guard error == nil, let response = response as? HTTPURLResponse else { return .failure(.noInternetConnection) }
        guard let data = data else { return .failure(.noData) }
        guard (200...299).contains(response.statusCode) else {
            return .failure(.badResponseWithStatus(code: StatusCode(rawValue: response.statusCode) ?? .unowned))
        }
        if let errorCode = checkErrorCode(data: data) { return .failure(.errorWithErrorCode(number: errorCode)) }
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            SBLogger.responseDecodedWithSuccess(for: type)
            return .success(decodedData)
        } catch let error as DecodingError {
            SBLogger.responseDecodedWithError(for: type, decodingError: error)
            return .failure(.failDecode)
        } catch {
            print("error: ", error)
            return .failure(.failDecode)
        }
    }
    
    func decodeResponse(data: Data?,
                        response: URLResponse?,
                        error: Error?) -> Result<Void, SDKError> {
        guard error == nil, let response = response as? HTTPURLResponse else { return .failure(.noInternetConnection) }
        guard let data = data else { return .failure(.noData) }
        if let errorCode = checkErrorCode(data: data) { return .failure(.errorWithErrorCode(number: errorCode)) }
        guard (200...299).contains(response.statusCode) else {
            return .failure(.badResponseWithStatus(code: StatusCode(rawValue: response.statusCode) ?? .unowned))
        }
        return .success(())
    }
    
    func decodeResponseFull<T: Codable>(data: Data?,
                                        response: URLResponse?,
                                        error: Error?,
                                        type: T.Type) -> Result<(result: T,
                                                                 headers: HTTPHeaders,
                                                                 cookies: [HTTPCookie]), SDKError> {
        
        if let error = systemError(error) {
            return .failure(error)
        }
        
        guard error == nil, let response = response as? HTTPURLResponse else { return .failure(.noInternetConnection) }
        guard let data = data else { return .failure(.noData) }
        guard (200...299).contains(response.statusCode) else {
            return .failure(.badResponseWithStatus(code: StatusCode(rawValue: response.statusCode) ?? .unowned))
        }
        if let errorCode = checkErrorCode(data: data) { return .failure(.errorWithErrorCode(number: errorCode)) }
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
            return .failure(.failDecode)
        } catch {
            print("error: ", error)
            return .failure(.failDecode)
        }
    }
    
    func decodeParametersFrom(url: URL) -> Result<BankModel, SDKError> {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return .failure(.badDataFromSBOL)
        }
        guard let queryItems = urlComponents.queryItems else {
            return .failure(.badDataFromSBOL)
        }
        var parameters = [String: String]()
        queryItems.forEach {
            if let value = $0.value {
                parameters[$0.name] = value
            }
        }
        if let error = parameters["error"] {
            SBLogger.logResponseFromSbolFailed(url, error: error)
            return .failure(checkBankError(error: error))
        }
        if let status = parameters["status"], status != "success" {
            SBLogger.logResponseFromSbolFailed(url, error: "status \(status)")
            return .failure(checkBankError(error: status))
        }
        SBLogger.logResponseFromSbolCompleted(parameters)
        return .success(BankModel(dictionary: parameters))
    }
    
    private func systemError(_ error: Error?) -> SDKError? {
    
        guard let error = error as? NSError else { return nil }

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
            return .ssl
        } else if timeOutErrors.contains(where: { $0.rawValue == error._code }) {
            return .timeOut
        } else {
            return nil
        }
    }
    
    private func checkBankError(error: String) -> SDKError {
        if error == "unauthorized_client" {
            return .unauthorizedClient
        } else {
            return .badDataFromSBOL
        }
    }
    
    private func checkErrorCode(data: Data) -> String? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
               let errorCode = json["errorCode"] as? String,
               errorCode != "0" {
                return errorCode
            } else {
                return nil
            }
        } catch {
            return nil
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
