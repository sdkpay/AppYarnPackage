//
//  CertsTarget.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 10.07.2023.
//

import Foundation

enum CertsTarget {
    case getCertsIft
    case getCertsPsi
    case getCertsSandbox
    case getCertsProm
}

extension CertsTarget: TargetType {
    var path: String {
        switch self {
        case .getCertsIft:
            return "/h1tg6t6xj4oszb2/CertConfigIFT.json"
        case .getCertsPsi:
            return "jempn80gspj2mb5/CertConfigPSI.json"
        case .getCertsSandbox:
            return "2r9tdyupd34ooc8/CertConfigSandBox.json"
        case .getCertsProm:
            return "48cm680qgjm61wc/CertConfigProm.json"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getCertsSandbox, .getCertsIft, .getCertsProm, .getCertsPsi:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getCertsSandbox, .getCertsIft, .getCertsProm, .getCertsPsi:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var sampleData: Data? {
        switch self {
        case .getCertsSandbox, .getCertsIft, .getCertsProm, .getCertsPsi:
            return StubbedResponse.certConfig.data
        }
    }
}
