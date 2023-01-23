//
//  BankApps.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 07.12.2022.
//

import UIKit

enum BankApp: String, CaseIterable {
    case sber
    case sbol
    
    var name: String {
        switch self {
        case .sber:
            return String(stringLiteral: .Auth.sberTitle)
        case .sbol:
            return String(stringLiteral: .Auth.sbolTitle)
        }
    }
    
    var link: String {
        switch self {
        case .sber:
            return AppSettings.sberAuthLink
        case .sbol:
            return AppSettings.sbolAuthLink
        }
    }

    var icon: UIImage? {
        switch self {
        case .sber:
            return .Auth.sberIcon
        case .sbol:
            return .Auth.sbolIcon
        }
    }
}
