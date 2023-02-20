//
//  BuildSettings.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 24.01.2023.
//

import Foundation

enum BuildSettings {
    static let needStubs = (Bundle.main.infoDictionary?["needStubs"] as? String == "YES")
}
