//
//  ParameterEncoding.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

typealias NetworkParameters = [String: Any]

protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: NetworkParameters) throws
}

enum EncoderError: String, Error {
    case missingUrl = "Url == nil"
    case missingParameters = "Parameters == nil"
    case encodingFailed = "Encoding failed"
}

// MARK: - URLParameterEncoder

struct URLParameterEncoder: ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: NetworkParameters) throws {
        guard let url = urlRequest.url else { throw EncoderError.missingUrl }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty else {
            throw EncoderError.encodingFailed
        }
        
        urlComponents.queryItems = [URLQueryItem]()
        for (name, value) in parameters {
            let item = URLQueryItem(name: name, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
            urlComponents.queryItems?.append(item)
        }
        urlRequest.url = urlComponents.url
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}

// MARK: - JSONParameterEncoder

struct JSONParameterEncoder: ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: NetworkParameters) throws {
        do {
            let json = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = json
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw EncoderError.encodingFailed
        }
    }
}
