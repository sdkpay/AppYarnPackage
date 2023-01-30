//
//  BuildSettings.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum BuildSettings {
    static let needStubs = ProcessInfo.processInfo.environment["STUBS_ENABLED"] != nil
}
