//
//  ConfigModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.03.2023.
//

import Foundation

enum BankUrlType {
    case auth
    case util
}

enum BankSchemeAuthType: String {
    case preffix
    case withOutPreffix
}

// MARK: - ConfigModel
struct ConfigModel: Codable {
    let localization: Localization
    let bankApps: [BankAppModel]
    let bankAppsBeta: [BankAppModel]?
    let schemas: Schemas
    let versionInfo: VersionInfo?
    let featuresToggle: [FeaturesToggle]
    let images: Images
    let certHashes: [String]?
}

struct VersionInfo: Codable {
    let deprecated: [String]
    let active: String
}

// MARK: - Localization
struct Localization: Codable {
    let authTitle: String
    let payLoading: String
    let connectTitle: String?
}

struct FeaturesToggle: Codable {
    let name: String
    var value: Bool
}

// MARK: - Schemas
struct Schemas: Codable {
    let dynatraceUrl: String
    let dynatraceId: String
    let getIpUrl: String?
}

struct BankAppModel: Codable {
    
    let appId: Int?
    let name: String
    let utilLink: String
    let authLink: String
    let iconURL: String?
}

struct BankApp: Codable {
    
    enum VersionType: Codable {
        case prom
        case beta
    }
    
    let appId: Int?
    let name: String
    let utilLink: String
    let authLink: String
    let iconURL: String?
    let versionType: VersionType
    
    func url(type: BankUrlType) -> String {
        
        switch type {
            
        case .auth:
            return authLink
        case .util:
            return utilLink
        }
    }
    
    init(_ model: BankAppModel, versionType: VersionType) {
        
        appId = model.appId
        name = model.name
        utilLink = model.utilLink
        authLink = model.authLink
        iconURL = model.iconURL
        self.versionType = versionType
    }
}

// MARK: - Images
struct Images: Codable {
    let logoIcon: String
    let logoClear: String
    let logoBlack: String?
}
