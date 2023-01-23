//
//  NetworkDecoding.swift
//  SberPaySDK
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
        guard error == nil, let response = response as? HTTPURLResponse else { return .failure(.noInternetConnection) }
        guard let data = data else { return .failure(.noData) }
        if let errorText = checkServerError(data: data) { return .failure(.errorFromServer(text: errorText)) }
        guard (200...299).contains(response.statusCode) else { return .failure(.badResponseWithStatus(code: response.statusCode)) }
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            return .success(decodedData)
        } catch {
            print(error)
            return .failure(.failDecode)
        }
    }
    
    func decodeResponse(data: Data?,
                        response: URLResponse?,
                        error: Error?) -> Result<Void, SDKError> {
        guard error == nil, let response = response as? HTTPURLResponse else { return .failure(.noInternetConnection) }
        guard let data = data else { return .failure(.noData) }
        if let errorText = checkServerError(data: data) { return .failure(.errorFromServer(text: errorText)) }
        guard (200...299).contains(response.statusCode) else { return .failure(.badResponseWithStatus(code: response.statusCode)) }
        return .success(())
    }
    
    func decodeParametersFrom(url: URL) -> Result<BankModel, SDKError> {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return .failure(.badDataFromSBOL)
        }
        guard let queryItems = urlComponents.queryItems else { return .failure(.badDataFromSBOL) }
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
        SBLogger.logResponseFromSbolCompleted(parameters)
        return .success(BankModel(dictionary: parameters))
    }
    
    private func checkBankError(error: String) -> SDKError {
        if error == "unauthorized_client" {
            return .unauthorizedClient
        } else {
            return .badDataFromSBOL
        }
    }
    
    private func checkServerError(data: Data) -> String? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
               let message = json["description"] as? String {
                return message
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
