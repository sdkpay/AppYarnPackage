//
//  SPayDebug.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.04.2023.
//

import Foundation

public final class SPayDebug: NSObject {
    /**
     Метод для установки моков, только для тестовых версий
     */

    public static func debugConfig(network: NetworkState, ssl: Bool) {
        BuildSettings.shared.networkState = network
        BuildSettings.shared.ssl = ssl
    }
}
