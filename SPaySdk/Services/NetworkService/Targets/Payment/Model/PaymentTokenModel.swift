//
//  PaymentTokenModel.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

enum SecureChallengeFactor: String {
    case sms = "SMSP"
    case hint = "HINT"
}

struct PaymentTokenModel: Codable {
    let paymentToken: String
    let initiateBankInvoiceId: String?
    let fraudMonСheckResult: FraudMonСheckResult?
}

struct FraudMonСheckResult: Codable {
    let actionCode: String
    let isClientBlock: Bool?
    let confirmMethodFactor: String
    let formParameters: FormParameters?
    
    var secureChallengeFactor: SecureChallengeFactor? {
        SecureChallengeFactor(rawValue: confirmMethodFactor)
    }
}

struct FormParameters: Codable {
    let header: String?
    let text: String?
    let textDecline: String?
    let buttonСonfirmText: String?
    let buttonInformText: String?
    let cybercabinetUrlAndroid: String?
    let cybercabinetUrlIOS: String?
}


