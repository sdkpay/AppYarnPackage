//
//  AppSettings.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.01.2023.
//

import Foundation

enum AppSettings {
    // dynatrace
    static let dynatraceId = "656e76e7-76f4-40ca-86bf-39db12cbc857"
    static let dynatraceUrl = "https://vito.sbrf.ru:443/mbeacon/7e4bdb68-cd47-4ecc-b649-69eb5cd44c91"
    static let dynatraceLogLevel = "OFF" // ALL
    
    // auth links
    static let sberAuthLink = "sberbankidexternallogin://sberbankid"
    static let sbolAuthLink = "sbolidexternallogin://sberbankid"
}
