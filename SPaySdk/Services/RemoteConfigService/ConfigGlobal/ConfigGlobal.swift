//
//  ConfigManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 21.04.2023.
//

import Foundation

enum ConfigGlobal {
    static let bankApp = UserDefaults.bankApp
    static let localization = UserDefaults.localization
    static let schemas = UserDefaults.schemas
    static let images = UserDefaults.images
}
