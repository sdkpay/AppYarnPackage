//
//  ConfigTarget.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.03.2023.
//

import Foundation

enum ConfigTarget {
    case getConfig
}

extension ConfigTarget: TargetType {
    var path: String {
        switch self {
        case .getConfig:
            return "sdk-gateway/v1/remoteConfigIOS"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getConfig:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getConfig:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getConfig:
            return try? Data(contentsOf: Files.remoteConfigJson.url)
        }
    }
}
