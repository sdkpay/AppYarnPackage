//
//  UIDevice+Extensions.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.08.2023.
//

import UIKit

extension UIDevice {
    
    var fullSystemVersion: String {
        "\(self.systemName) \(self.systemVersion)"
    }
}

