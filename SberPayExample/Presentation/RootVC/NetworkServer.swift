//
//  NetworkServer.swift
//  SPaySdkExample
//
//  Created by Арсений on 05.04.2023.
//

import UIKit

// MARK: - Empty
struct ResponseModel: Codable {
    let externalParams: ExternalParams
    
    struct ExternalParams: Codable {
        let sbolBankInvoiceId: String
    }
}

enum NetworkType: String {
    case sberbankIFT
    case sberbankPSI
}

// MARK: - ExternalParams

struct RequestHeandler {
    func response(schemaType: NetworkType, clouser: @escaping (ResponseModel?) -> Void) {
        let orderNumber = String(Int.random(in: Int.zero...Int.max))
        let url = "https://sb03.tst.rbstest.ru/payment/rest/register.do?returnUrl=https://sberbank.ru&amount=16500&orderBundle=%7B%22cartItems%22:%7B%22items%22:[%7B%22tax%22:%7B%22taxType%22:0%7D,%22itemAmount%22:16500,%22positionId%22:1,%22quantity%22:%7B%22value%22:165,%22measure%22:%22%D0%A1%E2%80%9A%22%7D,%22itemCode%22:%22130163%22,%22itemPrice%22:100,%22name%22:%2215%22%7D]%7D%7D&jsonParams=%7B%22app2app%22:%22true%22,%22app.osType%22:%22android%22,%22app.deepLink%22:%22https://sberbank.ru%22%7D&userName=781000012764-20162559-api&password=\(schemaType.rawValue)1&sessionTimeoutSecs=600000&orderNumber=\(orderNumber)"
        guard let url = URL(string: url) else {
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
        }
        .resume()
    }
    
    private func decode(data: Data) -> ResponseModel? {
        guard let model = try? JSONDecoder().decode(ResponseModel.self, from: data) else { return nil }
        return model
    }
}
