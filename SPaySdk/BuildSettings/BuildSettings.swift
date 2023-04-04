//
//  BuildSettings.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

public enum NetworkState: String, CaseIterable, Codable {
    case Test, Prod, Local, Psi
}

final class BuildSettings {
    var networkState = NetworkState.Prod
    var ssl = true

    static let shared = BuildSettings()
}
