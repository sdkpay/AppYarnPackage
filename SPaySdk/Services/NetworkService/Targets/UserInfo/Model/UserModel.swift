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
    
    var castToHelperType: HelperType? {
        switch self {
        case .sbp:
            return .sbp
        case .creditCard:
            return .credit
        case .debitCard:
            return nil
        case .unknown:
            return nil
        }
    }
    
    func equel(to helperType: HelperType) -> Bool {
        self.castToHelperType == helperType
    }
}

struct UserModel: Codable {
    let paymentToolInfo: PaymentToolInfo
    let merchantInfo: MerchantInfo
    let formInfo: FormInfo
    let promoInfo: PromoInfo
    let orderInfo: OrderInfo
    let userInfo: UserInfo
}

// MARK: - FormInfo
struct FormInfo: Codable {
    let notEnoughBalanceText, onlyPartPayText: String
}

// MARK: - MerchantInfo
struct MerchantInfo: Codable {
    let merchantName: String
    let logoURL: String?
    let bindingIsNeeded: Bool
    let bindingSafeText: String?

    enum CodingKeys: String, CodingKey {
        case merchantName
        case logoURL = "logoUrl"
        case bindingIsNeeded
        case bindingSafeText
    }
}

// MARK: - OrderInfo
struct OrderInfo: Codable {
    let orderAmount: OrderAmount
}

// MARK: - OrderAmount
struct OrderAmount: Codable {
    let amount: Int
    let currency: String
}

// MARK: - PaymentToolInfo
struct PaymentToolInfo: Codable {
    let paymentTool: [PaymentTool]
    let additionalCards, isSPPaymentToolsNeedUpdate: Bool?

    enum CodingKeys: String, CodingKey {
        case paymentTool = "paymentToolList", additionalCards
        case isSPPaymentToolsNeedUpdate = "isSpPaymentToolsNeedUpdate"
    }
}

// MARK: - PaymentToolList
struct PaymentTool: Codable {
    let isSPPaymentToolsPriority: Bool?
    let precalculateBonuses: String?
    let paymentSourceType, financialProductID: String
    let cardLogoURL: String
    let productName: String
    let paymentID: Int
    let cardNumber: String
    let isSPPaymentTools: Bool?
    let amountData: OrderAmount
    let priorityCard: Bool
    let paymentSystemType: String
    let countAdditionalCards: Int?

    enum CodingKeys: String, CodingKey {
        case isSPPaymentToolsPriority = "isSpPaymentToolsPriority"
        case precalculateBonuses
        case paymentSourceType
        case financialProductID = "financialProductId"
        case cardLogoURL = "cardLogoUrl"
        case productName
        case paymentID = "paymentId"
        case cardNumber
        case countAdditionalCards
        case isSPPaymentTools = "isSpPaymentTools"
        case amountData, priorityCard, paymentSystemType
    }
}

// MARK: - PromoInfo
struct PromoInfo: Codable {
    let bannerList: [BannerList]
    let hint: String
}

// MARK: - BannerList
struct BannerList: Codable, Hashable {
    let iconURL: String
    let buttons: [Button]
    let hint, type, header, text: String

    enum CodingKeys: String, CodingKey {
        case iconURL = "iconUrl"
        case buttons, hint, type, header, text
    }
    
    var bannerListType: BannerListType {
        BannerListType(rawValue: type) ?? .unknown
    }
}

// MARK: - Button
struct Button: Codable, Hashable {
    let type: String
    let deeplinkIos, deeplinkAndroid, title: String?
}

// MARK: - UserInfo
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
