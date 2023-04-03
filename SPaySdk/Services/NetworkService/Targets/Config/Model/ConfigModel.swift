//
//  ConfigModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.03.2023.
//

import Foundation

// MARK: - ConfigModel
struct ConfigModel: Codable {
    let version: String
    let localization: Localization
    let schemas: Schemas
    let apikey: [String]
    let images: Images
}

// MARK: - Localization
struct Localization: Codable {
    let authTitle: String
    let firstApp: String
    let secondApp: String
    let loadToFirstApp: String
    let loadToSecondApp: String
    let payWaiting: String
}

// MARK: - Schemas
struct Schemas: Codable {
    let authLinkFirstApp: String
    let authLinkSecondApp: String
    let payLinkFirstApp: String
    let payLinkSecondApp: String
    let dynatraceUrl: String
    let dynatraceId: String
}

// MARK: - Images
struct Images: Codable {
    let firstAppIcon: String
    let secondAppIcon: String
    let logoIcon: String
    let logoClear: String
}
