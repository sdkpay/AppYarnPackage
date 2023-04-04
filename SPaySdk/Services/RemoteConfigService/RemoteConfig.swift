//
//  RemoteConfig.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.03.2023.
//

import Foundation

final class RemoteConfig {
    static let shared = RemoteConfig()
    
    // DEBUG = false
    var needLogs = true
}
