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
    let count: Int
    let payments: [BankApp]
    let schemas: Schemas
    let apikey: [String]
    let images: Images
}

struct Payments: Codable {
    let date: String
    let amount: String
    let currencyCode: String
}
