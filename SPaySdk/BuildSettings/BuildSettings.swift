//
//  BuildSettings.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

public enum NetworkState: String, CaseIterable, Codable {
    case Mocker, Prom, Ift, Psi, Local
}

final class BuildSettings {
    var networkState = NetworkState.Prom
    var ssl = true

    static let shared = BuildSettings()
}
