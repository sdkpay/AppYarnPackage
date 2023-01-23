//
//  AuthTarget.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 10.11.2022.
//

import Foundation

enum AuthTarget {
    case getSessionId
}

extension AuthTarget: TargetType {

    var path: String {
        switch self {
        case .getSessionId:
            return ""
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getSessionId:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getSessionId:
            return .requestWithParameters(nil, bodyParameters: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
 
