//
//  SelfConfigCell.swift
//  Crypto
//
//  Created by Ипатов Александр Станиславович on 12.10.2023.
//

import Foundation

protocol SelfReusable {
    
    static var reuseId: String { get }
}

extension SelfReusable {
    
    static var reuseId: String {
        String(describing: self)
    }
}
