//
//  BuildSettings.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

public enum NetworkState: String, CaseIterable, Codable {
    case Test, Prod, Local
}

final class BuildSettings {
    var networkState = NetworkState.Prod
    var ssl = true

    static let shared = BuildSettings()
}
