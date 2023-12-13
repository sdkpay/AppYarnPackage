//
// UserModel.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum BannerListType: String {
    case sbp
    case creditCard
    case debitCard
    case unknown
}

struct User: Codable {
    let sessionId: String
    let userInfo: UserInfo
    let orderAmount: OrderAmount
    let paymentToolInfo: [PaymentToolInfo]
    let merchantName: String?
    let logoUrl: String?
    let additionalCards: Bool?
    let promoInfo: PromoInfo
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
    let promoInfo: PromoInfo
}

struct PromoInfo: Codable {
    let bannerList: [BannerList]
}

struct BannerList: Codable, Hashable {
    let deeplinkIos, deeplinkAndroid, type, iconUrl: String
    let text: String
    
    var title: String {
        
        switch bannerListType {
            
        case .sbp:
            return Strings.Helpers.Sbp.title
        case .creditCard:
            return Strings.Helpers.CreditCard.title
        case .debitCard:
            return Strings.Helpers.DebittCard.title
        case .unknown:
            return ""
        }
    }
    
    var bannerListType: BannerListType {
        BannerListType(rawValue: type) ?? .unknown
    }
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
