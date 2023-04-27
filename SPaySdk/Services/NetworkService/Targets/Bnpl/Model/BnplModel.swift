//
//  BnplModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import Foundation

// MARK: - ConfigModel
struct BnplModel: Codable {
    let isBnplEnabled: Bool
    let buttonBnpl: ButtonBnpl?
    let offerUrl: String?
    let offerText: String?
    let graphBnpl: GraphBnpl?
}

struct GraphBnpl: Codable {
    let header: String
    let content: String
    let count: Int?
    let text: String?
    let payments: [Payment]
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
