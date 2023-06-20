//
//  NetworkServer.swift
//  SPaySdkExample
//
//  Created by Арсений on 05.04.2023.
//

import UIKit
import SPaySdkDEBUG

// MARK: - Empty
struct ResponseModel: Codable {
    let externalParams: ExternalParams
    
    struct ExternalParams: Codable {
        let sbolBankInvoiceId: String
    }
}

enum NetworkType: String, RawRepresentable {
    case sberbankIFT
    case sberbankPSI
    
    init(from state: NetworkState) {
        switch state {
        case .Psi:
            self.init(rawValue: "sberbankPSI")!
        default:
            self.init(rawValue: "sberbankIFT")!
        }
    }
}

// MARK: - ExternalParams
enum NetError: Error {
    case urlError
    case errorResponse(text: String)
    case noData    
}
struct OrderService {
    private static var host = URL(string: "https://sb03.tst.rbstest.ru/payment/rest/register.do")!

    @available(iOS 13.0.0, *)
    static func registerToken(stand: NetworkType,
                              orderNumber: String,
                              amount: Int,
                              currency: Int) async throws -> ResponseModel {
        var request = URLRequest(url: host)
        request.httpMethod = "POST"
        var params: [String: Any] = [
            "userName": "781000012764-20162559-api",
            "password": stand.rawValue,
            "orderNumber": orderNumber,
            "amount": amount,
            "currency": currency,
            "returnUrl": "https://ya.ru",
            "description": "регистрация заказа с максимальным набором полей",
            "language": "ru",
            "pageView": "DESKTOP",
            "sessionTimeoutSecs": 6000,
            "expirationDate": "2023-12-16T23:59:59",
            "phone": "79959977757",
            "features": "FORCE_SSL"
        ]
        
        let jsonParams: [String: Any] = [
            "osType": "ios",
            "app2app": false,
            "web2app": true,
            "app.deepLink": "https://www.google.com/doodles"
        ]
        
        params["jsonParams"] = jsonParams
        try configRequest(urlRequest: &request, with: params)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let model = try JSONDecoder().decode(ResponseModel.self, from: data)
        return model
    }
    
    private static func configRequest(urlRequest: inout URLRequest, with parameters: [String: Any]) throws {
        do {
            let json = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = json
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw error
        }
    }
    func response(schemaType: NetworkType,
                  cost: String,
                  clouser: @escaping (Result<ResponseModel?, NetError>) -> Void) {
        let orderNumber = String(Int.random(in: Int.zero...Int.max))
        let url = "https://sb03.tst.rbstest.ru/payment/rest/register.do?returnUrl=https://sberbank.ru&amount=16500&orderBundle=%7B%22cartItems%22:%7B%22items%22:[%7B%22tax%22:%7B%22taxType%22:0%7D,%22itemAmount%22:\(cost),%22positionId%22:1,%22quantity%22:%7B%22value%22:165,%22measure%22:%22%D0%A1%E2%80%9A%22%7D,%22itemCode%22:%22130163%22,%22itemPrice%22:100,%22name%22:%2215%22%7D]%7D%7D&jsonParams=%7B%22app2app%22:%22true%22,%22app.osType%22:%22android%22,%22app.deepLink%22:%22https://sberbank.ru%22%7D&userName=781000012764-20162559-api&password=\(schemaType.rawValue)1&sessionTimeoutSecs=600000&orderNumber=\(orderNumber)"
        guard let url = URL(string: url) else {
            assertionFailure("urlComp is not allowed")
            clouser(.failure(NetError.urlError))
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error {
                    clouser(.failure(NetError.errorResponse(text: error.localizedDescription)))
                    return
                } else if let data {
                    let result = decode(data: data)
                    clouser(.success(result))
                    return
                } else {
                    clouser(.failure(NetError.noData))
                    return
                }
            }
        }
        .resume()
    }
    
    private func decode(data: Data) -> ResponseModel? {
        guard let model = try? JSONDecoder().decode(ResponseModel.self, from: data) else { return nil }
        return model
    }
}
