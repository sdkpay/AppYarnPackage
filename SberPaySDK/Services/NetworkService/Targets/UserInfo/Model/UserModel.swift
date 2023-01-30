//
// UserModel.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

struct User: Codable {
    let sessionId: String
    let userInfo: UserInfo
    let orderAmount: OrderAmount
    let paymentToolInfo: [PaymentToolInfo]
    let merchantName: String
    let logoUrl: String
}

struct OrderAmount: Codable {
    let amount: Int
    let currency: String
}

struct PaymentToolInfo: Codable {
    let paymentId: Int
    var priorityCard: Bool
    let paymentSourceType: String
    let financialProductId: Double
    let cardNumber: String
    let paymentSystemType: String
    let cardLogoUrl: String
    let amountData: OrderAmount
    
    var name: String {
        "\(paymentSystemType.capitalized) \(paymentSourceType)"
    }
}

struct UserInfo: Codable {
    let lastName: String
    let firstName: String
    let gender: Int
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var sdkGender: Gender {
        Gender(rawValue: gender) ?? .neutral
    }
}
