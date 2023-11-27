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

enum SecureChallengeState: String {
    case review = "REVIEW"
    case deny = "DENY"
}

struct PaymentTokenModel: Codable {
    let paymentToken: String?
    let initiateBankInvoiceId: String?
    let froudMonСheckResult: FroudMonСheckResult?
}

struct FroudMonСheckResult: Codable {
    let actionCode: String
    let isClientBlock: Bool?
    let confirmMethodFactor: String
    let formParameters: FormParameters?
    
    var secureChallengeFactor: SecureChallengeFactor? {
        SecureChallengeFactor(rawValue: confirmMethodFactor)
    }
    
    var secureChallengeState: SecureChallengeState? {
        SecureChallengeState(rawValue: actionCode)
    }
}

struct FormParameters: Codable {
    let header, text, textDecline, buttonСonfirmText: String?
    let buttonDeclineText, buttonInformText, cybercabinetURLAndroid, cybercabinetURLIOS: String?

    enum CodingKeys: String, CodingKey {
        case header, text, textDecline, buttonСonfirmText, buttonDeclineText, buttonInformText
        case cybercabinetURLAndroid = "cybercabinetUrlAndroid"
        case cybercabinetURLIOS = "cybercabinetUrlIOS"
    }
}
