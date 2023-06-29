//
//  LogService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.06.2023.
//

import Foundation

final class LogServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register(reference: {
            let service: LogService = DefaultLogService()
            return service
        })
    }
}

protocol LogService {
    func setLogsWritable(environment: SEnvironment)
}

final class DefaultLogService: LogService {
    func setLogsWritable(environment: SEnvironment) {
        var writeLogs = false
    
        switch environment {
        case .prod:
            writeLogs = false
        case .sandboxWithoutBankApp, .sandboxRealBankApp:
            writeLogs = true
        }
#if SDKDEBUG
        SBLogger.writeLogs = true
#else
        SBLogger.writeLogs = writeLogs
#endif
    }
}
