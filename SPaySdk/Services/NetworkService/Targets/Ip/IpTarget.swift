//
//  IpTarget.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.10.2023.
//

import Foundation

enum IpTarget {
    case getIp
}

extension IpTarget: TargetType {
    
    var path: String {
        switch self {
        case .getIp:
            return ""
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getIp:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getIp:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getIp:
            return try? Data(contentsOf: Files.Stubs.getIpJson.url)
        }
    }
}
