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
    
    var commission: Int? {
        singleProductSixPart?.first?.clientCommission
    }
    
    var finalCost: Int {
        parts.map({ $0.amount }).reduce(0, +)
    }
    
    var currencyCode: String {
        parts.first?.currencyCode ?? "643"
    }
}

struct Payment: Codable, Hashable {
    let date: String
    let amount: Int
    let currencyCode: String?
    let clientCommission: Int?
    
    var uid: String {
        UUID().uuidString
    }
}

struct ButtonBnpl: Codable {
    private let activeButtonLogo: String?
    private let inactiveButtonLogo: String?
    let header: String
    let content: String
    private let buttonLogo: String?
    private let buttonLogoInactive: String?
    
    var buttonLogoUrl: String {
        if let activeButtonLogo {
            return activeButtonLogo
        } else if let buttonLogo {
            return buttonLogo
        } else {
            return ""
        }
    }
    
    var inactiveButtonLogoUrl: String {
        if let inactiveButtonLogo {
            return inactiveButtonLogo
        } else if let buttonLogoInactive {
            return buttonLogoInactive
        } else {
            return ""
        }
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
