//
//  NetworkServer.swift
//  SPaySdkExample
//
//  Created by Арсений on 05.04.2023.
//

import UIKit

struct ResponseModel: Decodable {
    var orderId: String
}

enum Endpoints: String {
    case path = "https://sb03.tst.rbstest.ru/payment/rest/register.do"
    case userName = "781000012764-20162559-api"
    case password = "sberbankIFT1"
    case amount = "16500"
    case returnUrl = "https://sberbank.ru"
    
    static var orderNumber: String = {
        return String(Int.random(in: 0...99999999999))
    }()
    
    var description: String {
        switch self {
        case .path:
            return "path"
        case .userName:
            return "userName"
        case .password:
            return "password"
        case .amount:
            return "amount"
        case .returnUrl:
            return "returnUrl"
        }
    }
}

struct RequestHeandler {
    private var path: String
    private var headers: HTTPHeades = [:]
    
    init(path: String) {
        self.path = path
    }
    
    func response(clouser: @escaping (ResponseModel?) -> ()) {
        let items = [
            URLQueryItem(name: Endpoints.userName.description, value: Endpoints.userName.rawValue),
            URLQueryItem(name: "orderNumber", value: Endpoints.orderNumber),
            URLQueryItem(name: Endpoints.password.description, value: Endpoints.password.rawValue),
            URLQueryItem(name: Endpoints.amount.description, value: Endpoints.amount.rawValue),
            URLQueryItem(name: Endpoints.returnUrl.description, value: Endpoints.returnUrl.rawValue),
        ]
        var urlComp = URLComponents(string: path)
        urlComp?.queryItems = items
        guard let urlComp, let url = urlComp.url else {
            assertionFailure("urlComp is not allowed")
            clouser(nil)
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                guard error == nil, let data else {
                    assertionFailure("\(String(describing: request.url)) is not allowed")
                    clouser(nil)
                    return
                }
                let result = decode(data: data)
                clouser(result)
            }
        }.resume()
    }
    
    private func decode(data: Data) -> ResponseModel? {
        guard let model = try? JSONDecoder().decode(ResponseModel.self, from: data) else { return nil }
        return model
    }
}
