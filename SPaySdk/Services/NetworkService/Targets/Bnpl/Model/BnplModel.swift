//
//  BnplModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

struct BnplModel: Codable {
    let isBnplEnabled: Bool
    let buttonBnpl: ButtonBnpl
    let offerUrl: String?
    let offerText: String?
    let graphBnpl: GraphBnpl?
}

struct GraphBnpl: Codable {
    let header: String
    let content: String
    let count: String?
    let text: String?
    let payments: [Payment]
    
    var finalCost: Int {
        payments.map({ $0.amount }).reduce(0, +)
    }
    
    var currencyCode: String {
        payments.first?.currencyCode ?? "643"
    }
}

struct Payment: Codable {
    let date: String
    let amount: Int
    let currencyCode: String
}

struct ButtonBnpl: Codable {
    let activeButtonLogo: String
    let inactiveButtonLogo: String
    let header: String
    let content: String
}
