//
//  BuildSettings.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

final class BuildSettings {
    var needStubs = false
    var ssl = true

    static let shared = BuildSettings()
}
