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
    let froudMonСheckResult: FraudMonСheckResult?
}

struct FraudMonСheckError: Codable {
    let errorCode: String?
    let description: String?
    
    private var fraudMonСheckResult: FraudMonСheckResult?
    private var fraudMonCheckResult: FraudMonСheckResult?
    
    var result: FraudMonСheckResult? {
        
        if let fraudMonСheckResult {
            return fraudMonСheckResult
        } else if let fraudMonCheckResult {
            return fraudMonCheckResult
        } else {
            return nil
        }
    }
}

struct FraudMonСheckResult: Codable {
    let actionCode: String
    let isClientBlock: Bool?
    let confirmMethodFactor: String?
    let formParameters: FormParameters?
    
    var secureChallengeFactor: SecureChallengeFactor? {
        SecureChallengeFactor(rawValue: confirmMethodFactor ?? "")
    }
    
    var secureChallengeState: SecureChallengeState? {
        SecureChallengeState(rawValue: actionCode)
    }
}

struct FormParameters: Codable {
    let buttonConfirmText, buttonDeclineText, textDecline, header: String?
    let text, buttonInformText, cybercabinetUrlAndroid, cybercabinetUrlIOS: String?
}
