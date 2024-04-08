//
//  VersionСontrolManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.10.2023.
//

import Foundation

final class VersionСontrolManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(VersionСontrolManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: VersionСontrolManager = DefaultVersionСontrolManager()
            return service
        }
    }
}

protocol VersionСontrolManager {
    var isVersionDepicated: Bool { get }
    func setVersionsInfo(_ model: VersionInfo?)
}

final class DefaultVersionСontrolManager: VersionСontrolManager {
    
    var isVersionDepicated: Bool {
        validateVersionDepicated()
    }
    
    private var versionInfo: VersionInfo?
    
    func setVersionsInfo(_ model: VersionInfo?) {
        versionInfo = model
    }
    
    private func validateVersionDepicated() -> Bool {
        SBLogger.log("🧭 Check version model start")
        guard let versionInfo else { return false }
        SBLogger.log("🛠 SDK VERSION: \(Bundle.sdkVersion)")
        for version in versionInfo.deprecated where Bundle.sdkVersion.contains(version) {
            SBLogger.log("🛠 SDK VERSION: \(Bundle.sdkVersion) contains \(versionInfo.deprecated)")
            return true
        }
        SBLogger.log("🛠 SDK VERSION: \(Bundle.sdkVersion) not in deprecated list")
        return false
    }
}
