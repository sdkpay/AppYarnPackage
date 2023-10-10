//
//  ConfigModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.03.2023.
//

import Foundation

enum BankSchemeAuthType: String {
    case preffix
    case withOutPreffix
}

// MARK: - ConfigModel
struct ConfigModel: Codable {
    let version: String
    let localization: Localization
    let bankApps: [BankApp]
    let schemas: Schemas
    let bankSchemes: [BankScheme]
    let featuresToggle: [FeaturesToggle]
    let apikey: [String]
    let images: Images
}

// MARK: - Localization
struct Localization: Codable {
    let authTitle: String
    let payLoading: String
}

struct BankScheme: Codable {
    let scheme: String
    let authType: String
    
    var authTypeEnum: BankSchemeAuthType {
        BankSchemeAuthType(rawValue: authType) ?? .withOutPreffix
    }
}

struct FeaturesToggle: Codable {
    let name: String
    var value: Bool
}

// MARK: - Schemas
struct Schemas: Codable {
    let payLinkFirstApp: String
    let payLinkSecondApp: String
    let dynatraceUrl: String
    let dynatraceId: String
}

struct BankApp: Codable {
    let name, link, icon: String
}

// MARK: - Images
struct Images: Codable {
    let logoIcon: String
    let logoClear: String
}
