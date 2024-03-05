//
//  BnplModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

struct BnplModel: Codable {
    let isBnplEnabled: Bool
    let buttonBnpl: ButtonBnpl?
    let offerUrl: String?
    let offerText: String?
    let graphBnpl: GraphBnpl?
    
    var integrityCheck: Bool {
        buttonBnpl?.integrityCheck == true && graphBnpl != nil
    }
}

struct GraphBnpl: Codable {
    let header: String?
    let content: String?
    let text: String?
    private let payments: [Payment]?
    private let singleProductSixPart: [SingleProductSixPart]?
    
    var parts: [Payment] {
        if let payments = singleProductSixPart?.first?.payments {
            return payments
        } else if let payments {
            return payments
        } else {
            return []
        }
    }
    
    var finalCost: Int {
        parts.map({ $0.amount }).reduce(0, +)
    }
    
    var currencyCode: String {
        parts.first?.currencyCode ?? "643"
    }
}

struct Payment: Codable {
    let date: String
    let amount: Int
    let currencyCode: String?
    let clientCommission: Int?
}

struct ButtonBnpl: Codable {
    let activeButtonLogo: String?
    let inactiveButtonLogo: String?
    let header: String?
    let content: String?
    
    var integrityCheck: Bool {
        activeButtonLogo != nil && inactiveButtonLogo != nil && header != nil && content != nil
    }
}

struct SingleProductSixPart: Codable {
    let productName: String?
    let clientCommission: Int?
    let payments: [Payment]

    enum CodingKeys: String, CodingKey {
        case productName, clientCommission, payments
    }
}
