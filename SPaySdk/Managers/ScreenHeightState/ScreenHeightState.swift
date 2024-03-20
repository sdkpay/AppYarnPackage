//
//  ScreenHeightState.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.12.2023.
//

import UIKit

enum ScreenHeightState {
    
    case max
    case big
    case normal
    
    var multiplier: CGFloat {
        switch self {
        case .big:
            return 0.80
        case .normal:
            return 0.70
        case .max:
            return 0.95
        }
    }
    
    var height: CGFloat {
        UIScreen.main.bounds.height * self.multiplier
    }
}
