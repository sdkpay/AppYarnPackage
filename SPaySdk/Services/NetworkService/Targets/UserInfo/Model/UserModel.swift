//
// UserModel.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

struct User: Codable {
    let sessionId: String
    let userInfo: UserInfo
    let orderAmount: OrderAmount
    let paymentToolInfo: [PaymentToolInfo]
    let merchantName: String?
    let logoUrl: String?
    let additionalCards: Bool?
}

struct OrderAmount: Codable {
    let amount: Int
    let currency: String
}

struct AmountData: Codable {
    let amount: Double
    let currency: String
    
    var amountInt: Int {
        Int(amount * 100.0)
    }
}

struct PaymentToolInfo: Codable {
    let productName: String
    let paymentId: Int
    var priorityCard: Bool
    let paymentSourceType: String
    let financialProductId: String?
    let cardNumber: String
    let paymentSystemType: String
    let cardLogoUrl: String
    let countAdditionalCards: Int?
    let amountData: AmountData
//    let promoInfo: PromoInfo
}

struct PromoInfo: Codable {
    let bannerList: [BannerList]
}

struct BannerList: Codable {
    let deeplinkIos, deeplinkAndroid, type, iconUrl: String
    let text: String
}

struct UserInfo: Codable {
    let lastName: String
    let firstName: String
    let gender: Int?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var sdkGender: Gender {
        Gender(rawValue: gender ?? 2) ?? .neutral
    }
}
